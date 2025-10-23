-- ============================================================
-- E-Commerce Database - MySQL Physical Schema
-- 물리 스키마 (Physical Schema) for MySQL 8.0+
-- ============================================================

-- 데이터베이스 생성 및 선택
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE ecommerce_db;

-- ============================================================
-- 1. CUSTOMERS 테이블
-- ============================================================
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id     INT             NOT NULL AUTO_INCREMENT,
    customer_name   VARCHAR(100)    NOT NULL,
    customer_email  VARCHAR(255)    NOT NULL,
    customer_phone  VARCHAR(20)     NOT NULL,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY (customer_id),
    
    -- Unique Constraints
    UNIQUE KEY uk_customer_email (customer_email),
    
    -- Check Constraints (MySQL 8.0.16+)
    CONSTRAINT chk_customer_email_format 
        CHECK (customer_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_customer_phone_format 
        CHECK (customer_phone REGEXP '^[0-9]{3}-[0-9]{4}-[0-9]{4}$')
        
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='고객 정보 테이블';

-- Indexes
CREATE INDEX idx_customer_name ON customers(customer_name);


-- ============================================================
-- 2. PRODUCTS 테이블
-- ============================================================
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id          INT             NOT NULL AUTO_INCREMENT,
    product_name        VARCHAR(200)    NOT NULL,
    product_category    VARCHAR(100)    NOT NULL,
    product_price       DECIMAL(10,2)   NOT NULL,
    stock_quantity      INT             DEFAULT 0,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY (product_id),
    
    -- Check Constraints
    CONSTRAINT chk_product_price_positive 
        CHECK (product_price >= 0),
    CONSTRAINT chk_stock_quantity_non_negative 
        CHECK (stock_quantity >= 0)
        
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='제품 정보 테이블';

-- Indexes
CREATE INDEX idx_product_category ON products(product_category);
CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_product_price ON products(product_price);


-- ============================================================
-- 3. ORDERS 테이블
-- ============================================================
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id            INT             NOT NULL AUTO_INCREMENT,
    order_date          DATE            NOT NULL,
    customer_id         INT             NOT NULL,
    shipping_address    VARCHAR(500)    NOT NULL,
    billing_address     VARCHAR(500)    NOT NULL,
    payment_method      VARCHAR(50)     NOT NULL,
    payment_txn_id      VARCHAR(100)    NOT NULL,
    order_status        VARCHAR(50)     NOT NULL DEFAULT 'Processing',
    total_amount        DECIMAL(12,2)   DEFAULT 0,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY (order_id),
    
    -- Foreign Keys
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Unique Constraints
    UNIQUE KEY uk_payment_txn_id (payment_txn_id),
    
    -- Check Constraints
    CONSTRAINT chk_payment_method 
        CHECK (payment_method IN ('Card', 'BankTransfer', 'KakaoPay', 'Payco', 'NaverPay', 'TossPay')),
    CONSTRAINT chk_order_status 
        CHECK (order_status IN ('Processing', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    CONSTRAINT chk_order_date 
        CHECK (order_date <= CURDATE()),
    CONSTRAINT chk_total_amount_non_negative 
        CHECK (total_amount >= 0)
        
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='주문 정보 테이블';

-- Indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_payment_txn ON orders(payment_txn_id);


-- ============================================================
-- 4. ORDER_ITEMS 테이블
-- ============================================================
DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    order_item_id   INT             NOT NULL AUTO_INCREMENT,
    order_id        INT             NOT NULL,
    product_id      INT             NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10,2)   NOT NULL,
    discount        DECIMAL(10,2)   DEFAULT 0,
    subtotal        DECIMAL(12,2)   GENERATED ALWAYS AS ((quantity * unit_price) - discount) STORED,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY (order_item_id),
    
    -- Foreign Keys
    CONSTRAINT fk_order_items_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_order_items_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Unique Constraints
    UNIQUE KEY uk_order_product (order_id, product_id),
    
    -- Check Constraints
    CONSTRAINT chk_quantity_positive 
        CHECK (quantity > 0),
    CONSTRAINT chk_unit_price_positive 
        CHECK (unit_price >= 0),
    CONSTRAINT chk_discount_non_negative 
        CHECK (discount >= 0)
        
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='주문 항목 테이블 (주문-제품 다대다 관계)';

-- Indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);


-- ============================================================
-- 5. REVIEWS 테이블
-- ============================================================
DROP TABLE IF EXISTS reviews;

CREATE TABLE reviews (
    review_id       INT             NOT NULL AUTO_INCREMENT,
    order_id        INT             NOT NULL,
    product_id      INT             NOT NULL,
    customer_id     INT             NOT NULL,
    review_rating   TINYINT         NOT NULL,
    review_comment  TEXT            NULL,
    is_verified     BOOLEAN         DEFAULT FALSE,
    helpful_count   INT             DEFAULT 0,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY (review_id),
    
    -- Foreign Keys
    CONSTRAINT fk_reviews_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_reviews_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_reviews_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Unique Constraints
    UNIQUE KEY uk_review_order_product (order_id, product_id),
    
    -- Check Constraints
    CONSTRAINT chk_review_rating_range 
        CHECK (review_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_helpful_count_non_negative 
        CHECK (helpful_count >= 0)
        
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='고객 리뷰 테이블';

-- Indexes
CREATE INDEX idx_reviews_order ON reviews(order_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_customer ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(review_rating);
CREATE INDEX idx_reviews_created ON reviews(created_at);


-- ============================================================
-- 6. WISHLIST 테이블 (추가 기능)
-- ============================================================
DROP TABLE IF EXISTS wishlist;

CREATE TABLE wishlist (
    wishlist_id     INT         NOT NULL AUTO_INCREMENT,
    customer_id     INT         NOT NULL,
    product_id      INT         NOT NULL,
    added_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY (wishlist_id),
    
    -- Foreign Keys
    CONSTRAINT fk_wishlist_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_wishlist_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Unique Constraints
    UNIQUE KEY uk_wishlist_customer_product (customer_id, product_id)
    
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='고객 위시리스트 테이블';

-- Indexes
CREATE INDEX idx_wishlist_customer ON wishlist(customer_id);
CREATE INDEX idx_wishlist_product ON wishlist(product_id);


-- ============================================================
-- 뷰(View) 생성
-- ============================================================

-- 고객별 주문 요약 뷰
CREATE OR REPLACE VIEW v_customer_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_email,
    c.customer_phone,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_amount,
    MAX(o.order_date) AS last_order_date,
    COUNT(DISTINCT r.review_id) AS total_reviews
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
LEFT JOIN reviews r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_email, c.customer_phone;


-- 제품별 판매 통계 뷰
CREATE OR REPLACE VIEW v_product_statistics AS
SELECT 
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_price,
    p.stock_quantity,
    COUNT(DISTINCT oi.order_item_id) AS times_ordered,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.subtotal), 0) AS total_revenue,
    COALESCE(AVG(r.review_rating), 0) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS review_count
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.product_price, p.stock_quantity;


-- 주문 상세 정보 뷰
CREATE OR REPLACE VIEW v_order_details AS
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount,
    c.customer_id,
    c.customer_name,
    c.customer_email,
    p.product_id,
    p.product_name,
    p.product_category,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.subtotal,
    r.review_rating,
    r.review_comment
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN reviews r ON o.order_id = r.order_id AND p.product_id = r.product_id;


-- 일일 매출 통계 뷰
CREATE OR REPLACE VIEW v_daily_sales AS
SELECT 
    DATE(o.order_date) AS sales_date,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
    SUM(o.total_amount) AS daily_revenue,
    AVG(o.total_amount) AS avg_order_value,
    SUM(oi.quantity) AS total_items_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY DATE(o.order_date);


-- ============================================================
-- 트리거(Trigger) 생성
-- ============================================================

-- 주문 항목 추가/수정 시 주문 총액 자동 업데이트
DELIMITER //

CREATE TRIGGER trg_update_order_total_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END//

CREATE TRIGGER trg_update_order_total_after_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END//

CREATE TRIGGER trg_update_order_total_after_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM order_items
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END//

-- 주문 항목 추가 시 재고 감소
CREATE TRIGGER trg_decrease_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END//

-- 주문 취소 시 재고 복구
CREATE TRIGGER trg_restore_stock_after_cancel
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'Cancelled' AND OLD.order_status != 'Cancelled' THEN
        UPDATE products p
        JOIN order_items oi ON p.product_id = oi.product_id
        SET p.stock_quantity = p.stock_quantity + oi.quantity
        WHERE oi.order_id = NEW.order_id;
    END IF;
END//

DELIMITER ;


-- ============================================================
-- 저장 프로시저(Stored Procedure) 생성
-- ============================================================

DELIMITER //

-- 주문 생성 프로시저
CREATE PROCEDURE sp_create_order(
    IN p_customer_id INT,
    IN p_shipping_address VARCHAR(500),
    IN p_billing_address VARCHAR(500),
    IN p_payment_method VARCHAR(50),
    IN p_payment_txn_id VARCHAR(100),
    OUT p_order_id INT
)
BEGIN
    INSERT INTO orders (
        order_date, customer_id, shipping_address, billing_address,
        payment_method, payment_txn_id, order_status
    ) VALUES (
        CURDATE(), p_customer_id, p_shipping_address, p_billing_address,
        p_payment_method, p_payment_txn_id, 'Processing'
    );
    
    SET p_order_id = LAST_INSERT_ID();
END//

-- 주문 항목 추가 프로시저
CREATE PROCEDURE sp_add_order_item(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_discount DECIMAL(10,2)
)
BEGIN
    DECLARE v_unit_price DECIMAL(10,2);
    
    -- 제품 가격 조회
    SELECT product_price INTO v_unit_price
    FROM products
    WHERE product_id = p_product_id;
    
    -- 주문 항목 추가
    INSERT INTO order_items (
        order_id, product_id, quantity, unit_price, discount
    ) VALUES (
        p_order_id, p_product_id, p_quantity, v_unit_price, p_discount
    );
END//

-- 고객 통계 조회 프로시저
CREATE PROCEDURE sp_get_customer_stats(
    IN p_customer_id INT
)
BEGIN
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_email,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent,
        AVG(o.total_amount) AS avg_order_value,
        COUNT(DISTINCT r.review_id) AS total_reviews,
        AVG(r.review_rating) AS avg_rating_given
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
    LEFT JOIN reviews r ON c.customer_id = r.customer_id
    WHERE c.customer_id = p_customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_email;
END//

DELIMITER ;


-- ============================================================
-- 물리 스키마 특성
-- ============================================================

/*
✅ MySQL 최적화 사항:

1. 스토리지 엔진: InnoDB
   - 트랜잭션 지원 (ACID)
   - 외래키 제약조건 지원
   - 행 수준 잠금
   - 크래시 복구

2. 문자셋: UTF8MB4
   - 이모지 지원
   - 국제화 지원
   - 완전한 유니코드 지원

3. 인덱스 전략:
   - PRIMARY KEY: 자동 클러스터드 인덱스
   - FOREIGN KEY: 자동 인덱스 생성
   - 검색 컬럼: B-Tree 인덱스
   - 복합 인덱스: 조회 패턴 최적화

4. AUTO_INCREMENT:
   - 자동 ID 생성
   - 순차적 증가

5. TIMESTAMP:
   - 자동 생성/수정 시간 추적
   - 타임존 지원

6. GENERATED COLUMN:
   - 계산된 컬럼 자동 유지
   - 저장 공간 효율

7. 트리거:
   - 비즈니스 로직 자동화
   - 데이터 일관성 유지

8. 뷰:
   - 복잡한 쿼리 단순화
   - 데이터 접근 추상화

9. 저장 프로시저:
   - 비즈니스 로직 캡슐화
   - 네트워크 트래픽 감소
*/
