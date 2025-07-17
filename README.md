# Blognificent

A modern, feature-rich blog application built with Django, Tailwind CSS, and DaisyUI.

![Django](https://img.shields.io/badge/Django-5.2.4-green)
![Python](https://img.shields.io/badge/Python-3.13-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Features

- **Responsive Design**: Built with Tailwind CSS and DaisyUI for a modern, mobile-friendly interface
- **Post Management**: Create, edit, and publish blog posts with draft/published status
- **Tagging System**: Organize posts with tags
- **Comments**: Allow readers to comment on posts
- **RSS Feed**: Provide an RSS feed for subscribers
- **Sitemap**: XML sitemap for better SEO
- **Email Sharing**: Share posts via email
- **REST API**: Full API access to posts and comments
- **Custom Error Pages**: Styled 403, 404, and 500 error pages
- **Logging**: Comprehensive error logging

## Technologies Used

- **Backend**: Django 5.2.4, Python 3.13
- **Frontend**: Tailwind CSS, DaisyUI
- **Database**: SQLite (default)
- **API**: Django REST Framework
- **Form Styling**: django-crispy-forms with crispy-tailwind
- **Tagging**: django-taggit
- **Deployment**: Docker, Gunicorn
- **Configuration**: python-decouple

## Installation

### Prerequisites

- Python 3.13+
- Docker and Docker Compose (optional, for containerized deployment)

### Local Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/SenzoEarl/blognificent.git
   cd blognificent
   ```

2. Create a virtual environment and activate it:
   ```bash
   python -m venv venv
   # On Windows
   venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create a `.env` file in the project root with the following variables:
   ```
   SECRET_KEY=your_secret_key
   DEBUG=True
   EMAIL_HOST_USER=your_email@gmail.com
   EMAIL_HOST_PASSWORD=your_email_password
   DEFAULT_FROM_EMAIL=your_email@gmail.com
   ```

5. Run migrations:
   ```bash
   python manage.py migrate
   ```

6. Create a superuser:
   ```bash
   python manage.py createsuperuser
   ```

7. Run the development server:
   ```bash
   python manage.py runserver
   ```

8. Access the application at http://127.0.0.1:8000/

## Docker Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/SenzoEarl/blognificent.git
   cd blognificent
   ```

2. Create a `.env` file as described in the local setup.

3. Build and run the Docker container:
   ```bash
   docker-compose up -d --build
   ```

4. Access the application at http://localhost:8000/

## Docker Workflow with GitHub Actions

This project includes a GitHub Actions workflow for automating Docker image building and deployment:

1. **Automatic Builds**: Docker images are automatically built when:
   - Code is pushed to the main/master branch
   - A new tag with 'v*' pattern is created (e.g., v1.0.0)
   - A pull request is opened against main/master branch

2. **Container Registry**: Images are pushed to GitHub Container Registry (ghcr.io) and tagged with:
   - Branch name for branch pushes
   - PR number for pull requests
   - Semantic version for tag pushes (v1.0.0, v1.0, etc.)
   - Commit SHA

3. **Automated Testing**: After building the image, tests are automatically run to ensure everything works correctly.

4. **Using the Container Image**:
   ```bash
   # Pull the latest image
   docker pull ghcr.io/senzoearl/blognificent:latest
   
   # Run the container
   docker run -p 8000:8000 --env-file .env ghcr.io/senzoearl/blognificent:latest
   ```

5. **For Development**: You can still use docker-compose as described above for local development.

## Django CI Workflow with GitHub Actions

This project includes a GitHub Actions workflow for Django continuous integration:

1. **Automated Testing**: 
   - Runs Django tests with `python manage.py test`
   - Measures test coverage with the coverage tool
   - Performs code formatting checks with Black
   - Runs security scans with Bandit and Safety

2. **Code Quality**:
   - Lints code with Flake8 to catch errors and enforce style
   - Checks import sorting with isort
   
3. **Database Integrity**:
   - Verifies that all migrations are properly created

4. **When It Runs**:
   - On pushes to main, master, and develop branches
   - On pull requests to main, master, and develop branches

5. **Benefits**:
   - Catches errors early in the development process
   - Ensures consistent code style and quality
   - Prevents security vulnerabilities
   - Maintains database schema integrity

## Usage

### Admin Interface

Access the admin interface at `/admin/` to manage posts, comments, and users.

### Blog Features

- **View Posts**: Browse all posts on the home page
- **Filter by Tag**: View posts by tag at `/tag/<tag_slug>/`
- **Post Details**: View post details at `/<year>/<month>/<day>/<slug>/`
- **Comments**: Add comments to posts
- **Share Posts**: Share posts via email

### API Endpoints

- **List Posts**: GET `/api/posts/`
- **Post Detail**: GET `/api/posts/<slug>/`
- **Create Comment**: POST `/api/posts/<post_id>/comments/`

## Project Structure

```
blognificent/
├── blog/                  # Main blog application
│   ├── migrations/        # Database migrations
│   ├── templatetags/      # Custom template tags
│   ├── admin.py           # Admin configuration
│   ├── models.py          # Data models
│   ├── views.py           # View functions
│   ├── urls.py            # URL routing
│   └── ...
├── blognificent/          # Project configuration
│   ├── settings.py        # Django settings
│   ├── urls.py            # Main URL routing
│   └── ...
├── static/                # Static files (CSS, JS, images)
├── templates/             # HTML templates
├── media/                 # User-uploaded files
├── logs/                  # Log files
├── Dockerfile             # Docker configuration
├── docker-compose.yml     # Docker Compose configuration
└── requirements.txt       # Python dependencies
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Senzo Maseko - [senzo.e.maseko@gmail.com](mailto:senzo.e.maseko@gmail.com)

## Acknowledgements

- Django Documentation
- Tailwind CSS
- DaisyUI