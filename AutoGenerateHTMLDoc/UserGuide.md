daux文档开源工具使用：

mac：

1.安装PHP and Composer

composer global require daux/daux.io

2.下载daux的工具

<https://github.com/dauxio/daux.io>

3.将准备好的md文件，放到上述下载文件夹下的docs文件夹下，生成的目录层级关系是按照docs下文件的组织目录形式

4.文档生成

在上述下载的文件夹下使用daux generate，请确保$PATH 包含 ~/.composer/vendor/bin，如果没有包含，可以使用命令设置环境变量PATH="$PATH:~/.composer/vendor/bin"

高级设置须知：

1.排序，可以使用数字开头，默认就会自动排序，建议采用形式：01_MyFile, 01_MyFolder

2.横向排版，需要在对应文件夹下创建_index.md文件

其他配置项目：

Configuration

To customize the look and feel of your documentation, you can create a config.json file in the of the /docs folder. The config.json file is a simple JSON object that you can use to change some of the basic settings of the documentation.

Title

Change the title bar in the docs

{

​	"title": "Daux.io"

}

Themes

We have 4 built-in Bootstrap themes. To use one of the themes, just set the theme option to one of the following:

daux-blue

daux-green

daux-navy

daux-red

{

  "html": { "theme": "daux-green" }

}