from psycopg2 import connect
from time import time as clock


# region: foundation

def timeit(name, f, n=5000, k=3):
    print(name)
    for j in xrange(k):
        t = clock()
        for i in xrange(n):
            f()
        t = clock() - t
        print(' #%d => %.1frps' % (j + 1, n / t))


# region: config

session = connect('dbname=main')


# region: models

class UserItem(object):

    def __init__(self, user_id, display_name, mail, phone, roles, status):
        self.user_id = user_id
        self.display_name = display_name
        self.mail = mail
        self.phone = phone
        self.roles = roles
        self.status = status


class User(object):

    def __init__(self, user_id='', status='1', customer_id='',
                 display_name='', mail='', phone1='', phone2='',
                 roles=''):
        self.user_id = user_id
        self.status = status
        self.customer_id = customer_id or ''
        self.display_name = display_name
        self.mail = mail
        self.phone1 = phone1
        self.phone2 = phone2
        self.roles = roles


# region: repository

def search_user(customer_id=None):
    c = session.cursor()
    c.callproc('membership.search_user', (customer_id,))
    return tuple(UserItem(*i) for i in c.fetchall())

def count_users(customer_id):
    c = session.cursor()
    c.callproc('membership.count_users', (customer_id,))
    return c.fetchone()[0]

def get_user(user_id):
    c = session.cursor()
    c.callproc('membership.get_user', (user_id,))
    r = c.fetchone()
    if not r:
        return None
    return User(*r)


# region: test cases

timeit('get user', lambda: get_user('1'))
timeit('search user', lambda: search_user('10'))
timeit('count users', lambda: count_users('10'))

# region: close everything
session.close()
