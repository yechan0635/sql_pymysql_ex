import random
import time
import pymysql
import datetime
from dotenv import load_dotenv
import os
from pygame import mixer

mixer.init()
load_dotenv()

# MySQL 설정
HOST = os.getenv("HOST")
PORT = int(os.getenv("PORT"))
USER = os.getenv("USER")
PASSWD = os.getenv("PASSWD")
DB1 = os.getenv("DB1")

def wordLoad():
    words = []
    try:
        with open('./data/word.txt', 'r') as f:
            for word in f:
                words.append(word.strip())
    except FileNotFoundError:
        print("word.txt 파일이 없습니다.")
        exit()
    return words

def getTime(start, end):
    exe_time = end - start
    exe_time = format(exe_time, ".3f")
    return exe_time

# === 난이도 선택 / 단어 필터 / 사운드 재생 ===
def choose_level():
    """난이도 선택 (Easy / Normal / Hard) + 라운드 수"""
    print("\n=== 난이도 선택 ===")
    print("1) Easy   - 짧은 단어, 4라운드")
    print("2) Normal - 보통 단어, 5라운드")
    print("3) Hard   - 긴 단어, 7라운드")
    sel = input("난이도를 선택하세요 (1~3): ").strip()
    if sel == '1':
        return "EASY", 4
    elif sel == '3':
        return "HARD", 7
    else:
        return "NORMAL", 5

def filter_words_by_level(words, level):
    """난이도별 단어 길이 기준으로 필터링"""
    if level == "EASY":
        filtered = [w for w in words if len(w) <= 5]
    elif level == "HARD":
        filtered = [w for w in words if len(w) >= 7]
    else:  # NORMAL
        filtered = [w for w in words if 5 < len(w) < 8]

    return filtered if len(filtered) >= 5 else words

def play(name: str):
    """사운드 재생(에러는 무시). assets/good.wav, assets/bad.wav 가정"""
    try:
        mixer.music.load(f'assets/{name}.wav')
        mixer.music.play()
    except Exception:
        pass

# === 메인 게임 실행 ===
def game_run(words, rounds=5):
    input("Ready? Press Enter Key!")
    game_cnt = 1
    corr_cnt = 0

    start = time.time()
    while game_cnt <= rounds:
        random.shuffle(words)
        que_word = random.choice(words)

        print()
        print("*Question # {}".format(game_cnt))
        print(que_word)

        t0 = time.time()
        input_word = input().strip()
        rt = time.time() - t0
        print()

        if str(que_word).strip() == input_word:
            play('good')
            print(f"Pass! (RT: {rt:.2f}s)")
            corr_cnt += 1
        else:
            play('bad')
            print(f"Wrong! (RT: {rt:.2f}s)")

        game_cnt += 1
        end = time.time()

    return corr_cnt, getTime(start, end)

# === DB 저장 ===
def inputDB(corr_cnt, exe_time):
    conn = None
    cursor = None
    try:
        conn = pymysql.connect(host=HOST, port=PORT, user=USER, passwd=PASSWD, db=DB1, charset='utf8')
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS game_records1(
                id INT AUTO_INCREMENT PRIMARY KEY,
                corr_cnt INT,
                record VARCHAR(255),
                regdate DATETIME
            )
        ''')

        cursor.execute(
            "INSERT INTO game_records1(corr_cnt, record, regdate) VALUES (%s, %s, %s)",
            (corr_cnt, exe_time, datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        )

        conn.commit()
    except pymysql.MySQLError as err:
        print(f"DB Error: {err}")
    finally:
        if conn and conn.open:
            cursor.close()
            conn.close()

# === 랭킹 출력 ===
def getDB():
    try:
        conn = pymysql.connect(host=HOST, port=PORT, user=USER, passwd=PASSWD, db=DB1, charset='utf8')
        cursor = conn.cursor()

        print("랭킹\t정답수\t걸린시간\t\t게임일시")
        print("-" * 56)

        cursor.execute("SELECT * FROM game_records1 ORDER BY corr_cnt DESC, record ASC LIMIT 10")
        rows = cursor.fetchall()

        for rank, row in enumerate(rows):
            regdate = row[3]
            reg_str = regdate.strftime('%Y-%m-%d %H:%M:%S') if hasattr(regdate, "strftime") else str(regdate)
            print(f"{rank + 1:^6}\t{row[1]:^6}\t{row[2]:^8} {reg_str:^22}")

    except pymysql.MySQLError as err:
        print(f"DB Error: {err}")
    finally:
        if conn and conn.open:
            conn.close()

# === 프로그램 실행 ===
if __name__ == '__main__':
    words = wordLoad()

    # 난이도 선택 및 단어 필터링
    level, rounds = choose_level()
    words = filter_words_by_level(words, level)

    # 게임 실행
    corr_cnt, exe_time = game_run(words, rounds=rounds)

    # DB 저장
    inputDB(corr_cnt, exe_time)

    print("-" * 56)
    pass_line = max(3, rounds // 2)
    if corr_cnt >= pass_line:
        print("결과 : 합격")
    else:
        print("불합격")
    print(f"난이도: {level} | 라운드: {rounds}")
    print(f"게임 시간: {exe_time}초 | 정답 개수: {corr_cnt}")
    print("-" * 56)

    getDB()
    print("-" * 56)
