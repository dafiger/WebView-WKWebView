#!/bin/bash
# chmod 755 xxx.sh

# 定义颜色
HighLightColor='\033[0;36m'
DefaultColor='\033[0;m'

# 仓库地址
HTTPSRepositoryPath=''
# 版本号
UpVersion=''
# 确认状态
ConfirmStatus='N'

# 输入仓库地址
InputRepositoryPath() {
    echo -e "\n"
    read -p 'Please input your Repository Path: ' HTTPSRepositoryPath
    if 
        test -z ${HTTPSRepositoryPath};
    then
        InputRepositoryPath
    fi
}

# 输入版本号
InputVersion() {
	echo -e "\n"
	read -p 'Please input version: ' UpVersion
	if 
    	test -z ${UpVersion};
    then
    	InputVersion
    fi
}

# 审查输入内容
CheckInfomation() {
    InputRepositoryPath
    InputVersion

    echo -e "\n================================================"
    echo -e "  Repository Path     :  ${HighLightColor}${HTTPSRepositoryPath}${DefaultColor}"
    echo -e "  Version             :  ${HighLightColor}${UpVersion}${DefaultColor}"
    echo -e "================================================\n"
}

# 循环检查
while [ ${ConfirmStatus} != 'y' -a ${ConfirmStatus} != 'Y' ]
do
    if 
        [ ${ConfirmStatus} == 'n' -o ${ConfirmStatus} == 'N' ]; 
    then
        CheckInfomation
    fi
    read -p 'Are you sure? (y/n):' ConfirmStatus
done

# git add .
# git commit -m "update to JSAndNativeDemo tag:${UpVersion}"
# git tag ${UpVersion}
# git push
# git push --tags
# pod repo push ${SpecName} JSAndNativeDemo.podspec --verbose --allow-warnings --use-libraries --use-modular-headers

echo "Start upload..."
git init
git remote add origin ${HTTPSRepositoryPath}
git add .
git commit -m "update to JSAndNativeDemo tag:${UpVersion}"
git push origin master -f 
git tag ${UpVersion}
# git push
git push --tags

echo "Upload finished"



