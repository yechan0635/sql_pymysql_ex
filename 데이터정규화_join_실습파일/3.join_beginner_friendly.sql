-- ============================================================
-- 초보자를 위한 SQL JOIN 실습 문제
-- 초급 10개 + 중급 10개
-- ============================================================

USE ecommerce_db;

-- ============================================================
-- 📖 JOIN이란?
-- ============================================================
/*
JOIN은 두 개 이상의 테이블을 연결해서 데이터를 조회하는 방법입니다.

예시:
- 주문 테이블에는 customer_id만 있음
- 고객 이름을 보려면 customers 테이블과 연결 필요
- JOIN을 사용하면 주문 정보와 고객 이름을 함께 볼 수 있음!

주요 JOIN 종류:
1. INNER JOIN: 양쪽 테이블에 모두 있는 데이터만
2. LEFT JOIN: 왼쪽 테이블의 모든 데이터 + 오른쪽에서 매칭되는 것
*/


-- ============================================================
-- 🌟 LEVEL 1: 초급 문제 (10개)
-- ============================================================
-- 천천히 하나씩 따라하세요!
-- 각 문제마다 실행해보고 결과를 확인하세요.


-- ============================================================
-- 초급 1번: 가장 기본적인 INNER JOIN
-- ============================================================
/*
📝 문제:
주문 번호와 그 주문을 한 고객의 이름을 함께 보여주세요.

💡 힌트:
- orders 테이블과 customers 테이블 사용
- customer_id로 연결
- INNER JOIN 사용

📊 어떤 데이터가 나올까요?
- 주문번호 | 고객이름
*/

-- 정답:
SELECT 
    o.order_id AS 주문번호,
    c.customer_name AS 고객이름
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
LIMIT 10;

-- 🎯 해설:
-- orders 테이블(o)과 customers 테이블(c)을
-- customer_id가 같은 것끼리 연결했습니다.


-- ============================================================
-- 초급 2번: 더 많은 정보 보기
-- ============================================================
/*
📝 문제:
주문 번호, 주문 날짜, 고객 이름, 고객 전화번호를 함께 보여주세요.

💡 힌트:
- 초급 1번과 비슷하지만 더 많은 컬럼을 선택
- SELECT 절에 원하는 컬럼을 추가하면 됨
*/

-- 정답:
SELECT 
    o.order_id AS 주문번호,
    o.order_date AS 주문날짜,
    c.customer_name AS 고객이름,
    c.customer_phone AS 전화번호
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC
LIMIT 10;

-- 🎯 해설:
-- JOIN으로 연결하면 양쪽 테이블의 컬럼을 모두 사용할 수 있습니다.


-- ============================================================
-- 초급 3번: 제품 정보와 연결하기
-- ============================================================
/*
📝 문제:
주문 항목에 제품 이름을 붙여서 보여주세요.
(주문 항목 ID, 제품 이름, 수량)

💡 힌트:
- order_items 테이블과 products 테이블 사용
- product_id로 연결
*/

-- 정답:
SELECT 
    oi.order_item_id AS 주문항목ID,
    p.product_name AS 제품이름,
    oi.quantity AS 수량
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
LIMIT 10;

-- 🎯 해설:
-- order_items에는 product_id만 있지만
-- products와 JOIN하면 제품 이름을 볼 수 있습니다.


-- ============================================================
-- 초급 4번: WHERE 조건 추가하기
-- ============================================================
/*
📝 문제:
'김민수' 고객의 주문 목록을 보여주세요.
(주문번호, 주문날짜, 고객이름)

💡 힌트:
- 초급 1번에 WHERE 조건만 추가
- customer_name = '김민수'
*/

-- 정답:
SELECT 
    o.order_id AS 주문번호,
    o.order_date AS 주문날짜,
    c.customer_name AS 고객이름
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_name = '김민수'
ORDER BY o.order_date DESC;

-- 🎯 해설:
-- JOIN 후에 WHERE 절로 원하는 데이터만 필터링할 수 있습니다.


-- ============================================================
-- 초급 5번: 3개 테이블 연결하기
-- ============================================================
/*
📝 문제:
주문 번호, 고객 이름, 제품 이름을 함께 보여주세요.

💡 힌트:
- orders, customers, order_items, products 테이블 필요
- 순서: orders → customers (고객 정보)
       orders → order_items (주문 항목)
       order_items → products (제품 정보)
*/

-- 정답:
SELECT 
    o.order_id AS 주문번호,
    c.customer_name AS 고객이름,
    p.product_name AS 제품이름,
    oi.quantity AS 수량
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
LIMIT 15;

-- 🎯 해설:
-- 여러 테이블을 차례로 연결할 수 있습니다.
-- orders를 중심으로 다른 테이블들을 붙였습니다.


-- ============================================================
-- 초급 6번: 특정 카테고리 제품 찾기
-- ============================================================
/*
📝 문제:
'컴퓨터/주변기기' 카테고리의 제품을 구매한 고객 이름과 제품명을 보여주세요.

💡 힌트:
- 초급 5번과 비슷
- WHERE 절에 product_category 조건 추가
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    p.product_name AS 제품명,
    p.product_category AS 카테고리,
    oi.quantity AS 수량
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category = '컴퓨터/주변기기'
ORDER BY c.customer_name
LIMIT 20;

-- 🎯 해설:
-- JOIN으로 모든 정보를 연결한 후
-- WHERE로 원하는 카테고리만 필터링했습니다.


-- ============================================================
-- 초급 7번: LEFT JOIN 맛보기
-- ============================================================
/*
📝 문제:
모든 고객의 이름과 주문 횟수를 보여주세요.
(주문하지 않은 고객도 포함, 주문 횟수는 0으로 표시)

💡 힌트:
- LEFT JOIN 사용 (고객 테이블이 왼쪽)
- COUNT 함수로 주문 횟수 세기
- GROUP BY로 고객별로 묶기
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    COUNT(o.order_id) AS 주문횟수
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY 주문횟수 DESC;

-- 🎯 해설:
-- LEFT JOIN은 왼쪽(customers) 테이블의 모든 행을 보여줍니다.
-- 주문이 없는 고객도 표시되며, 주문횟수가 0으로 나옵니다.


-- ============================================================
-- 초급 8번: 가격 정보 포함하기
-- ============================================================
/*
📝 문제:
각 주문 항목의 제품명, 수량, 단가, 총액을 보여주세요.

💡 힌트:
- order_items와 products JOIN
- 총액 = 수량 × 단가 (이미 subtotal로 계산되어 있음)
*/

-- 정답:
SELECT 
    p.product_name AS 제품명,
    oi.quantity AS 수량,
    oi.unit_price AS 단가,
    oi.subtotal AS 총액
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.subtotal DESC
LIMIT 15;

-- 🎯 해설:
-- subtotal은 자동으로 계산된 컬럼입니다.
-- (수량 × 단가) - 할인금액


-- ============================================================
-- 초급 9번: 특정 날짜의 주문 보기
-- ============================================================
/*
📝 문제:
2025년에 주문한 고객 이름과 제품명을 보여주세요.

💡 힌트:
- WHERE 절에 날짜 조건 추가
- order_date >= '2025-01-01'
*/

-- 정답:
SELECT 
    o.order_date AS 주문날짜,
    c.customer_name AS 고객이름,
    p.product_name AS 제품명
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.order_date >= '2025-01-01'
ORDER BY o.order_date DESC
LIMIT 20;

-- 🎯 해설:
-- WHERE 절로 날짜 범위를 지정할 수 있습니다.


-- ============================================================
-- 초급 10번: 배송 완료된 주문만 보기
-- ============================================================
/*
📝 문제:
배송 완료('Delivered') 상태인 주문의 고객 이름과 제품명을 보여주세요.

💡 힌트:
- WHERE 절에 order_status = 'Delivered'
*/

-- 정답:
SELECT 
    o.order_id AS 주문번호,
    c.customer_name AS 고객이름,
    p.product_name AS 제품명,
    o.order_status AS 주문상태
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
ORDER BY o.order_date DESC
LIMIT 20;

-- 🎯 해설:
-- order_status 컬럼으로 주문 상태를 확인할 수 있습니다.


-- ============================================================
-- ✅ 초급 완료! 중급으로 넘어가기 전 복습
-- ============================================================
SELECT '
🎉 초급 10문제 완료!

복습 포인트:
✓ INNER JOIN은 양쪽에 데이터가 있을 때만 표시
✓ LEFT JOIN은 왼쪽 테이블의 모든 데이터 표시
✓ ON 뒤에는 연결할 컬럼 조건
✓ WHERE로 추가 필터링 가능
✓ 여러 테이블을 연결할 수 있음

이제 중급으로 넘어갑니다! 💪
' AS 초급완료;


-- ============================================================
-- 🌟 LEVEL 2: 중급 문제 (10개)
-- ============================================================
-- 집계 함수와 그룹핑을 배워봅니다!


-- ============================================================
-- 중급 1번: 고객별 주문 횟수 세기
-- ============================================================
/*
📝 문제:
각 고객이 몇 번 주문했는지 세어주세요.
(고객이름, 주문횟수)

💡 힌트:
- COUNT() 함수 사용
- GROUP BY customer_id로 고객별로 묶기
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    COUNT(o.order_id) AS 주문횟수
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY 주문횟수 DESC;

-- 🎯 해설:
-- GROUP BY로 고객별로 묶고
-- COUNT로 각 고객의 주문 개수를 셉니다.


-- ============================================================
-- 중급 2번: 고객별 총 구매 금액
-- ============================================================
/*
📝 문제:
각 고객이 총 얼마를 구매했는지 계산하세요.
(고객이름, 총구매금액)

💡 힌트:
- SUM() 함수 사용
- total_amount 컬럼 합계
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    SUM(o.total_amount) AS 총구매금액
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.customer_name
ORDER BY 총구매금액 DESC;

-- 🎯 해설:
-- SUM()으로 금액을 합산합니다.
-- 취소된 주문은 제외했습니다.


-- ============================================================
-- 중급 3번: 제품별 판매 수량
-- ============================================================
/*
📝 문제:
각 제품이 총 몇 개 팔렸는지 보여주세요.
(제품명, 총판매수량)

💡 힌트:
- order_items의 quantity를 합산
- 제품별로 GROUP BY
*/

-- 정답:
SELECT 
    p.product_name AS 제품명,
    SUM(oi.quantity) AS 총판매수량,
    COUNT(oi.order_item_id) AS 판매횟수
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 총판매수량 DESC;

-- 🎯 해설:
-- 같은 제품이 여러 주문에 포함될 수 있으므로
-- quantity를 모두 합산해야 총 판매 수량을 알 수 있습니다.


-- ============================================================
-- 중급 4번: 2번 이상 주문한 고객 찾기
-- ============================================================
/*
📝 문제:
2번 이상 주문한 고객만 보여주세요.
(고객이름, 주문횟수)

💡 힌트:
- 중급 1번에 HAVING 절 추가
- HAVING COUNT(o.order_id) >= 2
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    COUNT(o.order_id) AS 주문횟수,
    SUM(o.total_amount) AS 총구매금액
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2
ORDER BY 주문횟수 DESC;

-- 🎯 해설:
-- WHERE: 개별 행을 필터링
-- HAVING: 그룹화된 결과를 필터링
-- 2번 이상 주문한 고객 = 충성 고객!


-- ============================================================
-- 중급 5번: 카테고리별 총 매출
-- ============================================================
/*
📝 문제:
제품 카테고리별로 총 매출을 계산하세요.
(카테고리, 총매출)

💡 힌트:
- order_items의 subtotal 합산
- product_category로 GROUP BY
*/

-- 정답:
SELECT 
    p.product_category AS 카테고리,
    COUNT(DISTINCT p.product_id) AS 제품수,
    SUM(oi.quantity) AS 판매수량,
    SUM(oi.subtotal) AS 총매출
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY p.product_category
ORDER BY 총매출 DESC;

-- 🎯 해설:
-- 어떤 카테고리가 가장 잘 팔리는지 알 수 있습니다.


-- ============================================================
-- 중급 6번: 평균 주문 금액 계산
-- ============================================================
/*
📝 문제:
각 고객의 평균 주문 금액을 계산하세요.
(고객이름, 주문횟수, 평균주문금액)

💡 힌트:
- AVG() 함수 사용
- ROUND()로 소수점 정리
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    COUNT(o.order_id) AS 주문횟수,
    SUM(o.total_amount) AS 총구매금액,
    ROUND(AVG(o.total_amount), 0) AS 평균주문금액
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.customer_name
ORDER BY 평균주문금액 DESC;

-- 🎯 해설:
-- AVG()로 평균을 구하고
-- ROUND()로 소수점을 정리했습니다.


-- ============================================================
-- 중급 7번: 주문하지 않은 고객 찾기
-- ============================================================
/*
📝 문제:
한 번도 주문하지 않은 고객을 찾으세요.
(고객이름, 이메일)

💡 힌트:
- LEFT JOIN 사용
- WHERE o.order_id IS NULL
*/

-- 정답:
SELECT 
    c.customer_name AS 고객이름,
    c.customer_email AS 이메일,
    c.customer_phone AS 전화번호
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 🎯 해설:
-- LEFT JOIN으로 모든 고객을 보고
-- order_id가 NULL인 경우 = 주문이 없는 고객
-- 이런 고객에게 할인 쿠폰을 보내면 좋겠죠?


-- ============================================================
-- 중급 8번: 제품별 평균 판매가
-- ============================================================
/*
📝 문제:
각 제품의 정가와 실제 평균 판매가를 비교하세요.
(제품명, 정가, 평균판매가)

💡 힌트:
- product_price: 정가
- unit_price: 실제 판매가
- AVG(unit_price): 평균 판매가
*/

-- 정답:
SELECT 
    p.product_name AS 제품명,
    p.product_price AS 정가,
    ROUND(AVG(oi.unit_price), 0) AS 평균판매가,
    ROUND(p.product_price - AVG(oi.unit_price), 0) AS 평균할인액
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.product_price
ORDER BY 평균할인액 DESC;

-- 🎯 해설:
-- 정가와 판매가의 차이 = 할인액
-- 어떤 제품이 가장 많이 할인되는지 알 수 있습니다.


-- ============================================================
-- 중급 9번: 리뷰가 있는 제품 조회
-- ============================================================
/*
📝 문제:
리뷰가 작성된 제품의 이름, 평균 평점, 리뷰 수를 보여주세요.

💡 힌트:
- products와 reviews JOIN
- AVG(review_rating): 평균 평점
- COUNT(review_id): 리뷰 수
*/

-- 정답:
SELECT 
    p.product_name AS 제품명,
    COUNT(r.review_id) AS 리뷰수,
    ROUND(AVG(r.review_rating), 1) AS 평균평점,
    MAX(r.review_rating) AS 최고평점,
    MIN(r.review_rating) AS 최저평점
FROM products p
INNER JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 평균평점 DESC, 리뷰수 DESC;

-- 🎯 해설:
-- 평점이 높고 리뷰가 많은 제품 = 인기 제품!


-- ============================================================
-- 중급 10번: 월별 주문 통계
-- ============================================================
/*
📝 문제:
2025년 각 월의 주문 수와 총 매출을 계산하세요.

💡 힌트:
- DATE_FORMAT(order_date, '%Y-%m'): 년-월 추출
- 월별로 GROUP BY
*/

-- 정답:
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS 주문월,
    COUNT(o.order_id) AS 주문수,
    COUNT(DISTINCT o.customer_id) AS 구매고객수,
    SUM(o.total_amount) AS 총매출,
    ROUND(AVG(o.total_amount), 0) AS 평균주문금액
FROM orders o
WHERE o.order_status != 'Cancelled'
  AND o.order_date >= '2025-01-01'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY 주문월 DESC;

-- 🎯 해설:
-- DATE_FORMAT으로 날짜를 월 단위로 묶었습니다.
-- 월별 매출 추이를 한눈에 볼 수 있습니다.


-- ============================================================
-- 🎉 완료! 축하합니다!
-- ============================================================
SELECT '
════════════════════════════════════════════════
🎊 축하합니다! 초급+중급 20문제 완료! 🎊
════════════════════════════════════════════════

✅ 배운 내용:

초급 (기본 JOIN):
1. INNER JOIN으로 테이블 연결
2. 여러 테이블 동시에 연결
3. WHERE로 조건 필터링
4. LEFT JOIN으로 누락 데이터 포함
5. 날짜와 상태로 필터링

중급 (집계와 그룹핑):
6. COUNT() - 개수 세기
7. SUM() - 합계 계산
8. AVG() - 평균 계산
9. GROUP BY - 그룹별 집계
10. HAVING - 집계 결과 필터링

════════════════════════════════════════════════

💡 다음 학습 단계:
- 복잡한 서브쿼리
- CASE WHEN 조건문
- 윈도우 함수
- 성능 최적화

════════════════════════════════════════════════

🎯 복습 팁:
각 문제를 다시 풀어보되, 조건을 바꿔서 연습하세요!
예: 다른 고객 이름, 다른 카테고리, 다른 날짜 등

화이팅! 💪
' AS 완료메시지;


-- ============================================================
-- 📝 스스로 풀어보기 (정답 없음)
-- ============================================================

/*
🎯 연습 문제: 정답을 보지 말고 스스로 풀어보세요!

1. '이영희' 고객의 모든 주문 내역을 보여주세요.

2. 가격이 50,000원 이상인 제품만 보여주세요.

3. 각 고객의 최근 주문 날짜를 찾으세요.
   힌트: MAX(order_date)

4. '음향기기' 카테고리의 총 매출을 계산하세요.

5. 3개 이상 주문한 고객의 이름을 보여주세요.

6. 할인을 받은 주문 항목만 보여주세요.
   힌트: WHERE discount > 0

7. 제품별로 총 할인 금액을 계산하세요.

8. 배송 완료된 주문의 평균 금액을 구하세요.

9. 리뷰 평점이 4점 이상인 제품을 찾으세요.

10. 2025년 2월의 총 주문 수를 계산하세요.

*/


-- ============================================================
-- 🔍 유용한 확인 쿼리
-- ============================================================

-- 테이블의 데이터 미리보기
SELECT '고객 테이블:' AS 테이블;
SELECT * FROM customers LIMIT 5;

SELECT '제품 테이블:' AS 테이블;
SELECT * FROM products LIMIT 5;

SELECT '주문 테이블:' AS 테이블;
SELECT * FROM orders LIMIT 5;

SELECT '주문 항목 테이블:' AS 테이블;
SELECT * FROM order_items LIMIT 5;

-- 전체 데이터 개수 확인
SELECT 
    '고객' AS 구분, COUNT(*) AS 개수 FROM customers
UNION ALL
SELECT '제품', COUNT(*) FROM products
UNION ALL
SELECT '주문', COUNT(*) FROM orders
UNION ALL
SELECT '주문항목', COUNT(*) FROM order_items
UNION ALL
SELECT '리뷰', COUNT(*) FROM reviews;
