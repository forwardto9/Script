#!/usr/bin/perl -w

use XML::Simple;
#use Data::Dumper;

use diagnostics;
use strict;
use utf8;

if ($^O =~ /MSWin/)
{
    binmode(STDOUT, ":encoding(gbk)");
}

sub checkReceiver;

printf "Start checking XML ....\n";

my $manifestFile;
if (@ARGV)
{
 $manifestFile = $ARGV[0];
 if ((length $manifestFile) == 0) {
        printf ("请输入内容完整的manifest文件的路径！如果是通过Jcenter集成，请使用Merged之后的文件! \n");
        exit 0;
 }
} else {
        printf ("请输入内容完整的manifest文件的路径！如果是通过Jcenter集成，请使用Merged之后的文件! \n");
        exit 0;
}

open(MANIFEST, $manifestFile);

my $manifestXML  = new XML::Simple;
my $xmlData = $manifestXML->XMLin($manifestFile);

#printf Dumper($xmlData);

foreach my $key (keys %$xmlData)
{

    #得到的都是对相应数据的引用
    my $dataRef = $xmlData->{$key};
    my $count = 0;
    if ($key eq "uses-permission") {

    } elsif ($key eq "uses-sdk") {

    } elsif($key eq "application") {

        #检查FCM APP 配置信息
        my $metaData  = $dataRef->{"meta-data"};
        if (ref($metaData) eq "ARRAY")
        {
            $count = @{$metaData};
            my @fcmMetaInfoList = ("com.google.android.gms.version");
            my %xgAppInfoMap;

            foreach my $appInfo (@fcmMetaInfoList)
            {
                 for (my $i = 0; $i < $count; $i++)
                {
                    if ($metaData->[$i]->{"android:name"} eq $appInfo)
                    {
                        $xgAppInfoMap{$appInfo} = 1;
                        last;
                    } else {
                        $xgAppInfoMap{$appInfo} = 0;
                    }
                }
            }

            while (my($key, $value) = each(%xgAppInfoMap))
            {
                if ($value == 0)
                {
                    printf "$key is not exist \n";
                }
            }
        } else {
            printf "Setting FCM google-play-services version occurs error! Please check it!";
        }

        #检查service配置
        my $serviceData = $dataRef->{"service"};

        if (ref($serviceData) eq "ARRAY")
        {
            $count = @{$serviceData};
            my @xgForceServiceList = ("com.tencent.android.fcm.XGFcmInstanceIDListenerService");
            my %xgServiceMap;

            foreach my $service (@xgForceServiceList)
            {
                 for (my $i = 0; $i < $count; $i++)
                {
                    if ($serviceData->[$i]->{"android:name"} eq $service)
                    {
                        $xgServiceMap{$service} = 1;
                        if ($serviceData->[$i]->{"android:exported"} ne "true")
                        {
                            printf "$service android:exported must be true! \n";
                        }
                        last;
                    } else {
                        $xgServiceMap{$service} = 0;
                    }
                }
            }

            while (my($key, $value) = each(%xgServiceMap))
            {
                if ($value == 0)
                {
                    printf "$key is not exist \n";
                }
            }
        }

        #检查receiver配置
        my $receiverData = $dataRef->{"receiver"};
        my @xgForceReceiverList = ("com.google.firebase.iid.FirebaseInstanceIdReceiver");
        my @xgForceReceiverIntentActionList = ("com.google.android.c2dm.intent.RECEIVE", "com.google.android.c2dm.intent.REGISTRATION");
        checkReceiver($receiverData, @xgForceReceiverList, @xgForceReceiverIntentActionList);

    }

}

close(MANIFEST);


sub checkReceiver
{
    my $receiverData = shift(@_);

    my $count = 0;
    my (@xgForceReceiverList, @xgForceReceiverIntentActionList) = @_;
        my %xgForceReceiverIntentActionMap;
        my %xgReceiverMap;
        if (ref($receiverData) eq "ARRAY")
        {
            $count = @{$receiverData};
            foreach my $receiver (@xgForceReceiverList)
            {
                 for (my $i = 0; $i < $count; $i++)
                {
                    if ($receiverData->[$i]->{"android:name"} eq $receiver)
                    {
                        #检查XGPushReceiver的Intent
                        my $intentFilter = $receiverData->[$i]->{"intent-filter"};
                        if (ref($intentFilter) eq "ARRAY")
                        {
                            my $jcount = @{$intentFilter};
                            foreach my $action (@xgForceReceiverIntentActionList)
                            {
                                 for(my $j = 0 ; $j < $jcount; $j++)
                                {
                                    my $actionList = $intentFilter->[$j]->{"action"};

                                    my $kcount = @{$actionList};
                                    for (my $k = 0 ; $k < $kcount; $k++)
                                    {
                                        if ($actionList->[$k]->{'android:name'} eq $action)
                                        {
                                            $xgForceReceiverIntentActionMap{$action} = 1;
                                            last;
                                        } else {
                                            $xgForceReceiverIntentActionMap{$action} = 0;
                                        }
                                    }

                                    last;
                                }
                            }
                        }

                        $xgReceiverMap{$receiver} = 1;
                        last;
                    } else {
                        $xgReceiverMap{$receiver} = 0;
                    }
                }
            }

            while (my($key, $value) = each(%xgReceiverMap))
            {
                if ($value == 0)
                {
                    printf "$key is not exist \n";
                }
            }

            while (my($key, $value) = each(%xgForceReceiverIntentActionMap))
            {
                if ($value == 0)
                {
                    printf "$key is not exist \n";
                }
            }
        } elsif (ref($receiverData) eq "HASH") {


            foreach my $receiver (@xgForceReceiverList)
            {
                    if ($receiverData->{"android:name"} eq $receiver)
                    {
                        #检查XGPushReceiver的Intent
                        my $intentFilter = $receiverData->{"intent-filter"};
                        if (ref($intentFilter) eq "ARRAY")
                        {
                            my $jcount = @{$intentFilter};
                            foreach my $action (@xgForceReceiverIntentActionList)
                            {
                                 for(my $j = 0 ; $j < $jcount; $j++)
                                {
                                    my $actionList = $intentFilter->[$j]->{"action"};

                                    my $kcount = @{$actionList};
                                    for (my $k = 0 ; $k < $kcount; $k++)
                                    {
                                        if ($actionList->[$k]->{'android:name'} eq $action)
                                        {
                                            $xgForceReceiverIntentActionMap{$action} = 1;
                                            last;
                                        } else {
                                            $xgForceReceiverIntentActionMap{$action} = 0;
                                        }
                                    }

                                    last;
                                }
                            }
                        }

                        $xgReceiverMap{$receiver} = 1;
                        last;
                    } else {
                        $xgReceiverMap{$receiver} = 0;
                    }

            }

            while (my($key, $value) = each(%xgReceiverMap))
            {
                if ($value == 0)
                {
                    printf "$key is not exist \n";
                }
            }

            while (my($key, $value) = each(%xgForceReceiverIntentActionMap))
            {
                if ($value == 0)
                {
                    printf "$key is not exist \n";
                }
            }
        }
}
