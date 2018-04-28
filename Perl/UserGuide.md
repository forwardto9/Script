Android 检测SDK接入脚本指导



1.安装Perl解释器

windows：http://strawberryperl.com   

2.非windows系统提示XML::Simple module未找到

执行命令：

cpan install XML::Simple

3.用法 

执行 perl perlfilepath

4.文件说明

xggradle.pl              检查gradle配置

xgfcmmanifes.pl     检查fcm配置

xghwmanifest.pl     检查华为配置

xgmanifest.pl		检查xg配置

xgmeizumanifest.pl 检查魅族配置

xgxiaomimanifest.pl 检查小米配置