import unittest
from sdc_consul.base import ConsulClient, ServiceNotFound


class TestKvStore(unittest.TestCase):
    """
    Test cases for KvStore class
    """
    def setUp(self):
        self.kv = ConsulClient(
            'localhost',
            '8500',
            'http'
        ).kv
        self.kv.delete('config/counting')

    def tearDown(self):
        self.kv.delete('config/counting')

    def test_set_kv(self):
        result = self.kv.set('config/counting', 'key1')
        self.assertTrue(result)

    def test_get_kv(self):
        self.kv.set('config/counting', 'key1')
        result = self.kv.get('config/counting')
        self.assertEqual('key1', result)

    def test_delete_kv(self):
        self.kv.set('config/counting', 'key1')
        result = self.kv.delete('config/counting')
        self.assertTrue(result)


class ServicesStore(unittest.TestCase):
    """
    Test cases for Services class
    """
    def setUp(self):
        self.services = ConsulClient(
            'localhost',
            '8500',
            'http'
        ).services
        self.delete_all_services()

    def tearDown(self):
        self.delete_all_services()

    def test_set_services(self):
        result = self.services.set('python-app', 'localhost', 8080)
        self.assertTrue(result)

    def test_get_services(self):
        self.services.set('python-app', 'localhost', 8080)
        result = self.services.get('python-app')
        self.assertTrue(result)
        self.assertEqual('python-app', result['ServiceName'])

    def test_list_services(self):
        self.services.set('python-app-1', 'localhost', 8080)
        self.services.set('python-app-2', 'localhost', 8080)
        result = self.services.list()
        self.assertEqual(2, len(result))

    def test_delete_services(self):
        result = self.services.delete('python-app')
        self.assertTrue(result)

    def test_exception_service_not_found(self):
        self.assertRaises(ServiceNotFound, self.services.get, 'python-app')

    def delete_all_services(self):
        for service in self.services.list().keys():
            self.services.delete(service)
