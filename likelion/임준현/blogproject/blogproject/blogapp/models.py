from django.db import models

class Blog(models.Model): # 모델 객체 상속 받아 선언
    title=models.CharField(max_length=200)
    body=models.TextField()
    date=models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title #제목이 앞에 뜨게 타이틀 속성을 지정

# Create your models here.
