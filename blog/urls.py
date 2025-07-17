from django.urls import path
from .feed import LatestPostsFeed
from blog.views import IndexView, PostDetailView, SharePostView, PostCommentView, PostListAPIView, PostDetailAPIView, \
    CommentCreateAPIView

app_name = 'blog'
urlpatterns = [
    path('', IndexView.as_view(), name='index'),
    path('<int:year>/<int:month>/<int:day>/<slug:post>/', PostDetailView.as_view(), name='post_detail'),
    path('<int:post_id>/share/', SharePostView.as_view(), name='share_post'),
    path('post/<int:post_id>/comment/', PostCommentView.as_view(), name='comments'),
    path('tag/<slug:tag_slug>/', IndexView.as_view(), name='list_by_tag'),
    path('feed/', LatestPostsFeed(), name='post_feed'),
    path('api/posts/', PostListAPIView.as_view(), name='api_post_list'),
    path('api/posts/<slug:slug>/', PostDetailAPIView.as_view(), name='api_post_detail'),
    path('api/posts/<int:post_id>/comments/', CommentCreateAPIView.as_view(), name='api_comment_create'),
]
