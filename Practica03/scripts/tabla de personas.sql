USE db_test;

DROP TABLE IF EXISTS tb_persons;

CREATE TABLE IF NOT EXISTS tb_persons (
    person_ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_ID INT NOT NULL UNIQUE,             -- <-- Corregido (sin UNSIGNED)
    courtesy_title VARCHAR(10) NULL,         
    given_names VARCHAR(150) NOT NULL,       
    family_names VARCHAR(150) NULL,          
    birth_date DATE NULL,                    
    gender_ID TINYINT UNSIGNED NULL,         
    country_code CHAR(2) NULL,               
    postal_code VARCHAR(15) NULL,            
    phone VARCHAR(25) NULL,                  
    status BIT(1) DEFAULT b'1',              
    creation_date DATETIME DEFAULT CURRENT_TIMESTAMP, 
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    deleted_at DATETIME NULL DEFAULT NULL,   
    CONSTRAINT fk_persons_users FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;