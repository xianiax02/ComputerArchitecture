from django.shortcuts import render, redirect, get_object_or_404
from .models import Blog
from django.utils import timezone
from .forms import BlogForm,BlogModelForm


def home(request):
    posts=Blog.objects.all()#데이터베이스에서 블로그 객체들을 모두 불러와서 html에 찍히게 하기
    #posts=Blog.objects.filter().order_by('-date')이건 최신거 위에로 정렬해서 갖고 오기 'date'는 옛날게 위에
    return render(request, 'index.html',{'posts':posts})
#블로그 글 작성 html보여주는 함수
def new(request):
    return render(request, 'new.html')
#블로그 글 저장해주는 함수
def create(request):
    if(request.method == 'POST'):
        post = Blog()
        post.title = request.POST['title']
        post.body = request.POST['body']
        post.date = timezone.now()
        post.save()
    return redirect('home')
#using django form
#get(입력값을 받을 수 있는 html을 갖다 줘야함) post(입력한 내용을 데이터베이스에 저장) 둘다 처리 가능
def formcreate(request):
    if request.method=='POST' :
        form=BlogForm(request.POST)
        if form.is_valid():
            post=Blog()
            post.title=form.cleaned_data['title']
            post.body=form.cleaned_data['body']
            post.save()
            return redirect('home')
    

        #입력 내용을 DB에 저장
    if(request.method=='GET'): 
        #입력을 받을 수 있는 html 갖다 주기
        form=BlogForm()
    return render(request,'formcreate.html', {'form':form})   
def modelformcreate(request):
    if request.method=='POST':
        form=BlogModelForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('home')
    if request.method=='GET':
        form=BlogModelForm()
    return render(request,'formcreate.html',{'form':form})
def detail(request,blog_id):
    blogdetail=get_object_or_404(Blog,pk=blog_id)
    #blog_id 번째 블로그 글을 데이터베이스로부터 갖고오는 코드
    return render(request,'detail.html',{'blog_detail':blogdetail})
    #blog_id 번째 블로그 글을 detail.html로 띄워주는 코드


# Create your views here.
