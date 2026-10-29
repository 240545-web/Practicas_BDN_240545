-- Fase 3: PostgreSQL 16+. CALL es atómico; no hay COMMIT dentro de las rutinas.
-- Puede usarse BEGIN; CALL ecommerce.sp_massive_user_generation(1); COMMIT;
-- pgcrypto debe estar instalado en public por el archivo 02_postgresql.sql.

CREATE OR REPLACE FUNCTION ecommerce.fn_gen_us_name() RETURNS TEXT
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    first_names TEXT[] := ARRAY['James', 'Olivia', 'William', 'Emma', 'Benjamin', 'Charlotte', 'Henry', 'Amelia', 'Michael', 'Sophia', 'Daniel', 'Isabella'];
    last_names TEXT[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller', 'Davis', 'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore'];
BEGIN
    RETURN first_names[1 + floor(random()*12)::int] || '|' || last_names[1 + floor(random()*12)::int];
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_gen_latam_name() RETURNS TEXT
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    first_names TEXT[] := ARRAY['Santiago', 'Valentina', 'Mateo', 'Camila', 'Sebastián', 'Mariana', 'Diego', 'Lucía', 'Alejandro', 'Daniela', 'Nicolás', 'Gabriela'];
    last_names TEXT[] := ARRAY['García', 'Rodríguez', 'Martínez', 'Hernández', 'López', 'González', 'Pérez', 'Sánchez', 'Ramírez', 'Torres', 'Flores', 'Rivera'];
BEGIN
    RETURN first_names[1 + floor(random()*12)::int] || '|' || last_names[1 + floor(random()*12)::int];
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_gen_random_date(min_age INT,max_age INT)
RETURNS DATE LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    oldest DATE;
    youngest DATE;
    born DATE;
    age_years INT;
BEGIN
    IF min_age IS NULL OR max_age IS NULL OR min_age<0 OR max_age<min_age OR max_age>120 THEN
        RAISE EXCEPTION 'Edades inválidas.';
    END IF;
    oldest := (CURRENT_DATE-make_interval(years=>max_age+1))::date+1;
    youngest := (CURRENT_DATE-make_interval(years=>min_age))::date;
    born := oldest+floor(random()*(youngest-oldest+1))::int;
    age_years := extract(year FROM age(CURRENT_DATE,born))::int;
    WHILE age_years < min_age OR age_years > max_age LOOP
        born := oldest+floor(random()*(youngest-oldest+1))::int;
        age_years := extract(year FROM age(CURRENT_DATE,born))::int;
    END LOOP;
    RETURN born;
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_get_random_active_product()
RETURNS BIGINT LANGUAGE plpgsql VOLATILE AS $$
DECLARE chosen BIGINT;
BEGIN
    SELECT id INTO chosen FROM ecommerce.tb_products
    WHERE deleted_at IS NULL AND current_stock>0
    ORDER BY random() LIMIT 1 FOR UPDATE;
    IF chosen IS NULL THEN RAISE EXCEPTION 'No hay productos activos con existencias.'; END IF;
    RETURN chosen;
END;
$$;

-- Responsabilidad: cuenta y ficha; misma transacción que el llamador.
CREATE OR REPLACE FUNCTION ecommerce.fn_create_user_person(
    p_name TEXT,p_country CHAR(2),p_birth DATE,p_deleted TIMESTAMP
) RETURNS BIGINT LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    token TEXT := replace(pg_catalog.gen_random_uuid()::text,'-','');
    created_user BIGINT;
BEGIN
    INSERT INTO ecommerce.tb_users(email,nickname,password,deleted_at)
    VALUES('mass_'||token||'@example.test','gen_'||token,
           public.crypt(pg_catalog.gen_random_uuid()::text,public.gen_salt('bf',10)),p_deleted)
    RETURNING id INTO created_user;
    INSERT INTO ecommerce.tb_people(user_id,given_names,family_names,birth_date,country_code,deleted_at)
    VALUES(created_user,split_part(p_name,'|',1),split_part(p_name,'|',2),p_birth,p_country,p_deleted);
    RETURN created_user;
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_assign_purchase(p_user_id BIGINT)
RETURNS VOID LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    selected_product BIGINT;
    created_cart BIGINT;
    created_order BIGINT;
    selected_price DECIMAL(12,2);
    selected_name VARCHAR(250);
    selected_method BIGINT;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM ecommerce.tb_users WHERE id=p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'La compra requiere un usuario activo.';
    END IF;
    selected_product := ecommerce.fn_get_random_active_product();
    SELECT current_price,name INTO selected_price,selected_name
    FROM ecommerce.tb_products WHERE id=selected_product FOR UPDATE;
    INSERT INTO ecommerce.tb_carts(user_id,status) VALUES(p_user_id,'checked_out') RETURNING id INTO created_cart;
    INSERT INTO ecommerce.tbd_shopping_cart(cart_id,user_id,product_id,quantity)
    VALUES(created_cart,p_user_id,selected_product,1);
    INSERT INTO ecommerce.tb_orders(user_id,cart_id,status,total_amount)
    VALUES(p_user_id,created_cart,'paid',selected_price) RETURNING id INTO created_order;
    INSERT INTO ecommerce.tb_order_items(order_id,product_id,product_name,quantity,unit_price)
    VALUES(created_order,selected_product,selected_name,1,selected_price);
    selected_method := 1+floor(random()*3)::int;
    INSERT INTO ecommerce.tb_payments(order_id,payment_method_id,amount,payment_status)
    VALUES(created_order,selected_method,selected_price,'Completed');
    UPDATE ecommerce.tb_products SET current_stock=current_stock-1
    WHERE id=selected_product AND deleted_at IS NULL AND current_stock>0;
    IF NOT FOUND THEN RAISE EXCEPTION 'No se pudo descontar inventario.'; END IF;
END;
$$;

-- CALL se ejecuta en una sola transacción; una excepción revierte el lote.
-- No se hace COMMIT interno para permitir también BEGIN/CALL/COMMIT del cliente.
CREATE OR REPLACE PROCEDURE ecommerce.sp_massive_user_generation(IN p_scenario INT)
LANGUAGE plpgsql AS $$
DECLARE
    total_count INT;
    counter INT := 0;
    active_count INT := 0;
    created_user BIGINT;
    generated_name TEXT;
    country_codes TEXT[] := ARRAY['MX','CO','AR','CL','PE','EC','CR','UY'];
    generated_country CHAR(2);
    generated_birth DATE;
    deleted_time TIMESTAMP;
    is_active BOOLEAN;
BEGIN
    IF p_scenario IS NULL OR p_scenario NOT IN(1,2,3) THEN
        RAISE EXCEPTION 'Escenario válido: 1, 2 o 3.';
    END IF;
    total_count := CASE p_scenario WHEN 1 THEN 1000 WHEN 2 THEN 2000 ELSE 7222 END;
    IF (SELECT count(*) FROM ecommerce.tbc_payment_methods WHERE id IN(1,2,3)) <> 3 THEN
        RAISE EXCEPTION 'Faltan métodos de pago 1, 2 o 3.';
    END IF;
    IF (SELECT count(*) FROM ecommerce.tbc_countries WHERE code IN('US','MX','CO','AR','CL','PE','EC','CR','UY')) <> 9 THEN
        RAISE EXCEPTION 'Ejecute primero las semillas de países.';
    END IF;
    WHILE counter < total_count LOOP
        IF p_scenario=1 THEN
            generated_name := ecommerce.fn_gen_us_name();
            generated_country := 'US';
        ELSE
            generated_name := ecommerce.fn_gen_latam_name();
            generated_country := country_codes[1+floor(random()*8)::int];
        END IF;
        generated_birth := ecommerce.fn_gen_random_date(18,CASE WHEN p_scenario=2 THEN 30 ELSE 80 END);
        is_active := TRUE;
        deleted_time := NULL;
        IF p_scenario=3 THEN
            is_active := (random() <= 0.85);
            IF NOT is_active THEN deleted_time := CURRENT_TIMESTAMP; END IF;
        END IF;
        created_user := ecommerce.fn_create_user_person(generated_name,generated_country,generated_birth,deleted_time);
        IF is_active THEN
            PERFORM ecommerce.fn_assign_purchase(created_user);
            active_count := active_count+1;
        END IF;
        counter := counter+1;
    END LOOP;
    RAISE NOTICE 'Escenario %: total %, activos %, bajas %, carritos/pedidos/pagos %',
        p_scenario,total_count,active_count,total_count-active_count,active_count;
END;
$$;

-- CALL ecommerce.sp_massive_user_generation(1);
-- CALL ecommerce.sp_massive_user_generation(2);
-- CALL ecommerce.sp_massive_user_generation(3);
