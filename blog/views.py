import logging

from django.contrib import messages
from django.core.mail import send_mail
from django.db.models import Count
from django.shortcuts import render, get_object_or_404, redirect
from django.utils.decorators import method_decorator
from django.utils.html import escape
from django.views import View
from django.views.decorators.http import require_POST
from django.views.generic import ListView, DetailView, FormView
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import generics, filters
from taggit.models import Tag

from blog.forms import EmailPostForm, CommentForm
from blog.models import Post
from blog.serializers import PostSerializer, CommentSerializer

logger = logging.getLogger(__name__)


# Create your views here.
class IndexView(ListView):
    model = Post
    context_object_name = "posts"
    paginate_by = 3
    template_name = "index.html"

    def get_queryset(self):
        try:
            queryset = Post.published.all()
            tag_slug = self.kwargs.get("tag_slug")
            if tag_slug:
                self.tag = get_object_or_404(Tag, slug=tag_slug)
                queryset = queryset.filter(tags__in=[self.tag])
            return queryset
        except Exception as e:
            logger.error(f"Error in IndexView queryset: {e}")
            messages.error(self.request, "Unable to load posts")
            return Post.published.none()

    def get_context_data(self, *, object_list=..., **kwargs):
        context = super().get_context_data(**kwargs)
        if hasattr(self, "tag"):
            context["tag"] = self.tag
        context["latest_posts"] = Post.published.order_by("-publish")[:5]
        return context


class PostDetailView(DetailView):
    model = Post
    template_name = "blog/post/detail.html"
    context_object_name = "post"  # Keep same context key as FBV

    def get_queryset(self):
        return Post.objects.filter(status=Post.Status.PUBLISHED)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        try:
            context["form"] = CommentForm()
            context["post_tags_ids"] = self.object.tags.values_list("id", flat=True)
            context["similar_posts"] = Post.published.filter(
                tags__in=context["post_tags_ids"]
            ).exclude(id=self.object.id)
            context["similar_posts"] = (
                context["similar_posts"]
                .annotate(same_tags=Count("tags"))
                .order_by("-same_tags", "-publish")[:4]
            )
            context["comments"] = self.object.comments.filter(active=True)
        except Exception as e:
            logger.error(f"Context Error in PostDetailView: {e}")
            messages.error(self.request, "There was an issue loading related content")
        return context

    def get_object(self, queryset=None):
        try:
            year = self.kwargs["year"]
            month = self.kwargs["month"]
            day = self.kwargs["day"]
            slug = self.kwargs["post"]
            return get_object_or_404(
                self.get_queryset(),
                slug=slug,
                publish__year=year,
                publish__month=month,
                publish__day=day,
            )
        except Exception as e:
            logger.error(f"Error loadig post detail: {e}")
            raise

    def post(self, request, *args, **kwargs):
        try:
            self.object = self.get_object()
            form = CommentForm(request.POST)

            if form.is_valid():
                # Extract and sanitize input
                cleaned = form.cleaned_data
                name = escape(cleaned["name"])
                email = escape(cleaned["email"])
                body = escape(cleaned["body"])

                # Save sanitized comment
                comment = form.save(commit=False)
                comment.post = self.object
                comment.name = name
                comment.email = email
                comment.body = body
                comment.save()

                messages.success(request, "Comment was posted successfully")
                return redirect(self.request.path_info)
            # Invalid form - show error and retain content
            messages.error(request, "Error in content submission")
            return self.render_to_response(self.get_context_data(form=form))
        except Exception as e:
            logger.error(f"Error submitting comment: {e}")
            messages.error(request, "An unexpected error occurred")
            return render(request, "assets/error/500.html", status=500)


class SharePostView(FormView):
    template_name = "blog/post/share.html"
    form_class = EmailPostForm

    def dispatch(self, request, *args, **kwargs):
        try:
            # Load the post and store it for later access
            self.blog_post = get_object_or_404(
                Post, id=kwargs["post_id"], status=Post.Status.PUBLISHED
            )
            return super().dispatch(request, *args, **kwargs)
        except Exception as e:
            logger.error(f"Share post dispatch error: {e}")
            return render(request, "assets/error/500.html")

    def get_context_data(self, **kwargs):
        # Inject post and sent flag into context
        context = super().get_context_data(**kwargs)
        context["post"] = self.blog_post
        context["sent"] = getattr(self, "sent", False)
        return context

    def form_valid(self, form):
        try:
            # Extract and sanitize form data
            cd = form.cleaned_data
            name = escape(cd["name"])
            sender_email = escape(cd["email"])
            recipient_email = escape(cd["to"])
            comment = escape(cd["comments"])

            # Build post URL and email content
            post_url = self.request.build_absolute_uri(
                self.blog_post.get_absolute_url()
            )
            subject = (
                f"{name} recommends that you read the post: {self.blog_post.title}"
            )
            message = f"Read '{self.blog_post.title}' at {post_url}\n\n{name}'s comments: {comment}"

            # Send email
            send_mail(subject, message, sender_email, [recipient_email])

            # Set success flag and re-render form with context
            self.sent = True
            messages.success(self.request, "Post was sent successfully")
            return self.render_to_response(self.get_context_data(form=form, cd=cd))
        except Exception as e:
            logger.error(f"Email Sharing Error: {e}")
            messages.error(self.request, "Failed to send mail")
            return self.render_to_response(self.get_context_data(form=form))


@method_decorator(require_POST, name="dispatch")
class PostCommentView(View):

    def post(self, request, post_id, *args, **kwargs):
        try:
            post = get_object_or_404(Post, id=post_id, status=Post.Status.PUBLISHED)
            comments = post.comments.filter(active=True)
            comment = None
            form = CommentForm(request.POST)

            if form.is_valid():
                comment = form.save(commit=False)
                comment.post = post
                comment.save()

                messages.success(
                    self.request, message="Comment was posted successfully"
                )
            else:
                messages.error(request, "Comment form has errors")

            return render(
                request,
                "blog/post/detail.html",
                {"post": post, "form": form, "comment": comment, "comments": comments},
            )
        except Exception as e:
            logger.error(f"Post Comment Error: {e}")
            return render(request, "assets/error/500.html", status=500)


class PostListAPIView(generics.ListAPIView):
    queryset = Post.published.all()
    serializer_class = PostSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ["tags__slug"]
    search_fields = ["title", "body"]


class PostDetailAPIView(generics.RetrieveAPIView):
    queryset = Post.published.all()
    serializer_class = PostSerializer
    lookup_field = "slug"


class CommentCreateAPIView(generics.CreateAPIView):
    serializer_class = CommentSerializer

    def perform_create(self, serializer):
        try:
            post_id = self.kwargs.get("post_id")
            post = get_object_or_404(Post, id=post_id)
            serializer.save(post=post)
        except Exception as e:
            logger.error(f"Error commenting via api: {e}")
            raise


def custom_404(request, exception):
    return render(request, "assets/error/404.html", status=404)


def custom_500(request):
    return render(request, "assets/error/500.html", status=500)


def custom_403(request, exception):
    return render(request, "assets/error/403.html", status=403)
