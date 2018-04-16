#!/usr/bin/perl -w

use diagnostics;
use strict;

if ($^O =~ /MSWin/)
{
    use utf8;
    binmode(STDOUT, ":encoding(gbk)");
}


my $gradleFile;
if (@ARGV)
{
 $gradleFile = $ARGV[0];
 if ((length $gradleFile) == 0) {
        printf ("请输入app目录下的Gradle文件路径！\n");
        exit 0;
 }
} else {
        printf ("请输入app目录下的Gradle文件路径！\n");
        exit 0;
}

open(GRADLE, $gradleFile);


my $isXingeJar = 0;
my $isXingewupJar = 0;
my $isXingemidJar = 0;
my $isHWJar = 0;
my $isMZJar = 0;
my $isMiJar = 0;
my %xgJarInfo = (
                 "com.tencent.xinge:xinge" => $isXingeJar,
                 "com.tencent.wup:wup" => $isXingewupJar,
                 "com.tencent.mid:mid" => $isXingemidJar,
                 "com.tencent.xinge:xghw" => $isHWJar,
                 "com.tencent.xinge:xgmz" => $isMZJar,
                 "com.tencent.xinge:mipush" => $isMiJar
                 );

while(<GRADLE>)
{
        chomp;
        my $currentLine = $_;
        if ($currentLine =~ /XG_ACCESS_ID/)
        { #检查信鸽AccessID的合法性
            my @xgAccessID = /\s{0,}(XG_ACCESS_ID)\s{0,}:\s{0,}"(.+)"/;
            if (@xgAccessID && (my $count = @xgAccessID) == 2)
            {
                my $accessID = $xgAccessID[1];
                if ($accessID =~ /^[21]/) {
                    printf "不是Android的Access ID\n"
                }
                if ($accessID =~ /[^0-9]/) {
                    printf "Access ID 存在非法字符\n";
                }

                if (length($accessID) != 10) {
                    printf "Access ID 长度不正确\n";
                }

             } else {
                printf "Gradle文件中未发现XG AccessID!\n"
             }
        } elsif ($currentLine =~ /XG_ACCESS_KEY/) { #检查信鸽AccessKey的合法性
            my @xgAccessKey = /\s{0,}(XG_ACCESS_KEY)\s{0,}:\s{0,}"(.+)"/;

             if (@xgAccessKey && (my $count = @xgAccessKey) == 2)
            {
                my $accessKey = $xgAccessKey[1];
                if ($accessKey =~ /[^A-Z0-9]/) {
                    printf "信鸽 Access Key 存在非法字符\n";
                }

                if (length($accessKey) != 12) {
                    printf "信鸽 Access Key 长度不正确\n";
                }

             } else {
                printf "Gradle文件中未发现信鸽 Access Key!\n"
             }
        } elsif ($currentLine =~ /HW_APPID/) { #检查华为APPID合法性
            my @hwApp = /\s{0,}(HW_APPID)\s{0,}:\s{0,}"(.+)"/;

             if (@hwApp && (my $count = @hwApp) == 2)
            {
                my $appID = $hwApp[1];
                printf "Access key is $appID \n";

                if ($appID =~ /[^0-9]/) {
                    printf "华为AppID 存在非法字符\n";
                }

             } else {
                printf "Gradle文件中未发现华为App ID! \n"
             }
        } elsif ( $isXingeJar != 1 &&  $currentLine =~ /com.tencent.xinge:xinge/) { #检查xg的基础包
            $xgJarInfo{"com.tencent.xinge:xinge"} = 1;
            $isXingeJar = 1;
        } elsif ( $isXingewupJar != 1 &&  $currentLine =~ /com.tencent.wup:wup/) { #检查wup包
            $xgJarInfo{"com.tencent.wup:wup"} = 1;
            $isXingewupJar = 1;
        } elsif ( $isXingemidJar != 1 &&  $currentLine =~ /com.tencent.mid:mid/) { #检查mid包
            $xgJarInfo{"com.tencent.mid:mid"} = 1;
            $isXingemidJar = 1;
        } elsif ( $isHWJar != 1 &&  $currentLine =~ /com.tencent.xinge:xghw/) { #检查HW包
            $xgJarInfo{"com.tencent.xinge:xghw"} = 1;
            $isHWJar = 1;
        } elsif ( $isMZJar != 1 &&  $currentLine =~ /com.tencent.xinge:xgmz/) { #检查MZ包
            $xgJarInfo{"com.tencent.xinge:xgmz"} = 1;
            $isMZJar = 1;
        } elsif ( $isMiJar != 1 &&  $currentLine =~ /com.tencent.xinge:mipush/) { #检查MI包
            $xgJarInfo{"com.tencent.xinge:mipush"} = 1;
            $isMiJar = 1;
        }
}

#显示检查结果
while (my($key, $value) = each(%xgJarInfo))
{
    if ($value == 0)
    {
         printf "$key jar package 不存在!  请在Gradle文件中添加编译依赖! \n";
    }
}



close(GRADLE);
