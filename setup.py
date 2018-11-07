import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="hashtags",
    version="0.0.1",
    author="Forest Mars",
    author_email="themarsgroup@gmail.com",
    description="Coding exercise for Eigen Tehnologies",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/forestmars/createhashtags",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3.6",
        "Operating System :: OS Independent",
    ],
    # install_requires = ["Flask==1.0.2"],
)
