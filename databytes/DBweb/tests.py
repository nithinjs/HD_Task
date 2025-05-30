from django.test import TestCase, Client
from django.urls import reverse
from DBweb.models import Project

class ProjectModelTest(TestCase):
    def setUp(self):
        self.project = Project.objects.create(
            ProjectName='Test Project',
            ProjectShortDescription='A short description',
            ProjectDescription='A longer description of the test project.',
            ProjectLeader='Alice',
            LeaderEmail='alice@example.com'
        )

    def test_str_returns_project_name(self):
        """__str__() should return the ProjectName."""
        self.assertEqual(str(self.project), 'Test Project')


class IndexViewTest(TestCase):
    def setUp(self):
        self.client = Client()

    def test_index_status_code(self):
        """GET / should return HTTP 200."""
        response = self.client.get(reverse('index'))
        self.assertEqual(response.status_code, 200)

    def test_index_uses_index_template(self):
        """The index view should use index.html."""
        response = self.client.get(reverse('index'))
        self.assertTemplateUsed(response, 'index.html')
