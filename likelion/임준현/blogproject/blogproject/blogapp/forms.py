from django import forms
from .models import Blog

class BlogForm(forms.Form):
    #내가 입력받고자 하는 값들
    title=forms.CharField()
    body=forms.CharField(widget=forms.Textarea)

class BlogModelForm(forms.ModelForm):
    class Meta:
        model=Blog
        #fields='__all__' 속성 전부 다 상속
        fields=['title','body'] #어떤 속성을 받을지 리스트 형태로 선언
        #기존의 블로그 클래스를 이용하여 필드를 선언한다는 차이점/ 기존 장고 폼은 함수마다 클래스를 새로 생성하여 저장한다는 차이점
