from django.conf.urls import patterns, include, url
from django.contrib import admin
import views

urlpatterns = patterns('',
    url(r'^$', views.homeInput),
    url(r'^query/$', views.homeInputJson),
    url(r'^haskell/$', views.callHaskell),
)
