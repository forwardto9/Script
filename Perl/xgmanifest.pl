#!/usr/bin/perl -w

use XML::Simple;
use Data::Dumper;

use diagnostics;
use strict;

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
        #数组
        $count = @{$dataRef};
        my @forcedPermissionList = ("android.permission.INTERNET", "android.permission.READ_PHONE_STATE", "android.permission.ACCESS_WIFI_STATE", "android.permission.ACCESS_NETWORK_STATE", "android.permission.WAKE_LOCK", "android.permission.VIBRATE");
        my @suggestPermissionList = ("android.permission.RECEIVE_USER_PRESENT", "android.permission.RECEIVE_BOOT_COMPLETED");
        my %forcedPermissionMap;
        my %suggestPermissionMap;
        foreach my $permission (@forcedPermissionList)
        {
            for(my $i = 0; $i < $count; $i++)
            {
                if ($permission eq $dataRef->[$i]->{'android:name'})
                {
                    $forcedPermissionMap{$permission} = 1;
                    last;
                } else {
                    $forcedPermissionMap{$permission} = 0;
                }
            }
        }


        while (my($key, $value) = each(%forcedPermissionMap))
        {
            if ($value == 0)
            {
                printf "$key is not exist \n";
            }
        }


        foreach my $permission (@suggestPermissionList)
        {
            for(my $i = 0; $i < $count; $i++)
            {
                if ($permission eq $dataRef->[$i]->{'android:name'})
                {
                    $suggestPermissionMap{$permission} = 1;
                    last;
                } else {
                    $suggestPermissionMap{$permission} = 0;
                }
            }
        }

        while (my($key, $value) = each(%suggestPermissionMap))
        {
            if ($value == 0)
            {
                printf "$key is not exist, we suggest you add this permission  \n";
            }
        }
    } elsif ($key eq "uses-sdk") {
        if ($dataRef->{"android:minSdkVersion"} < 8)
        {
            printf "android:minSdkVersion lower than 8, it is should set higher than 8 \n";
        }

        if ($dataRef->{"android:targetSdkVersion"} < 14)
        {
            printf "android:targetSdkVersion lower than 14, it is should set higher than 14 \n";
        }
    } elsif($key eq "application") {

        #检查XG APP 配置信息
        my $metaData  = $dataRef->{"meta-data"};
        if (ref($metaData) eq "ARRAY")
        {
            $count = @{$metaData};
            my @xgAppInfoList = ("XG_V2_ACCESS_ID", "XG_V2_ACCESS_KEY");
            my %xgAppInfoMap;

            foreach my $appInfo (@xgAppInfoList)
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
            printf "Setting XG App information occurs error! Please check access id and access key!";
        }


        #检查activity配置

        my $activityData = $dataRef->{"activity"};

        if (ref($activityData) eq "ARRAY") {
            $count = @{$activityData};
            my $xgActivityIsExist = 0;
            for (my $i  = 0; $i < $count; $i++)
            {
                my $activity = $activityData->[$i];

                if ($activity->{"android:name"} eq "com.tencent.android.tpush.XGPushActivity")
                {
                    $xgActivityIsExist = 1;
                    if ($activity->{"android:exported"} eq "false")
                    {
                        printf "XGPushActivity's android:exported should be false! \n";
                    }
                    last;
                }
            }

            if ($xgActivityIsExist == 0)
            {
                printf "com.tencent.android.tpush.XGPushActivity is not exist, please add it into manifest file! \n";
            }
        }  elsif (ref($activityData) eq "HASH") {
        }

        #检查service配置
        my $serviceData = $dataRef->{"service"};

        if (ref($serviceData) eq "ARRAY")
        {
            $count = @{$serviceData};
            my @xgForceServiceList = ("com.tencent.android.tpush.service.XGPushServiceV3", "com.tencent.android.tpush.rpc.XGRemoteService");
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
        my @xgForceReceiverList = ("com.tencent.android.tpush.XGPushReceiver");
        my @xgForceReceiverIntentActionList = ("com.tencent.android.tpush.action.PUSH_MESSAGE", "com.tencent.android.tpush.action.FEEDBACK", "com.tencent.android.tpush.action.SDK", "com.tencent.android.tpush.action.INTERNAL_PUSH_MESSAGE", "android.net.conn.CONNECTIVITY_CHANGE");
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
