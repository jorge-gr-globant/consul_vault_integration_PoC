from setuptools import setup

setup(
    name='sdc_consul',
    packages=['sdc_consul'],
    version='0.1',
    license='MIT',
    description='Consul library tailored for sdc needs',
    author='Services Plaform Pod',
    author_email=['jorge.gomez1@smiledirectclub.com', 'gerald.alba@smiledirectclub.com'],
    url='https://github.com/user/reponame',
    download_url='https://github.com/user/reponame/archive/v_01.tar.gz',
    keywords=['SOME', 'MEANINGFULL', 'KEYWORDS'],
    install_requires=[
        'python-consul'
    ],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Build Tools',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],
)
