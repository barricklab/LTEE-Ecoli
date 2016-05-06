from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url('mutations', views.mutations, name='mutations'),
    url('search', views.search, name='search'),
    url('results', views.search, name='results'),
]
