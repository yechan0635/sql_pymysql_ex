# sql과 pymysql 실습
--
# sql 실습
폴더:sql_ex

# pymysql 실습 환경 셋팅
## 가상환경 셋팅
```
# 새로운 가상 환경 만들기
conda create -n llm_env python=3.10

#가상환경 활성화
conda activate llm_env


#jupyter lab에 가상환경 연동하기
- Jupyter 노트북에서 파이썬 코드를 실행할 수 있는 파이썬 커널
pip install ipykernel

- jupyter lab에 가상환경(llm_env) 등록하기
python -m ipykernel install --user --name llm_env
```

# 라이브러리 설치
```
- 파이썬과 mysql 연동하기 위한 라이브러리
pip install PyMySQL
```