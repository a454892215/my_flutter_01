# my_flutter_01

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



1. 使用Android studio创建好项目
2. 安装https://pub.dev/packages/get_cli
3. 使用命令后创建模块
   get create page:splash
   get create page:home

替换启动图： ./flutterw pub run flutter_native_splash:create

打包命令： ./flutterw build apk --release

// 打包出arm平台的包：包含 arm64-v8a:2, armeabi-v7a:2  (26.3MB)
./flutterw build apk --release --target-platform android-arm,android-arm64

// 打包出arm平台的包：包含 arm64-v8a， 而不包含armeabi-v7a， (14.8MB)
fvm flutter build apk --release --target-platform android-arm64 --split-per-abi

/Users/llpp/Library/Android/sdk/cmdline-tools/latest/bin/apkanalyzer

./flutterw pub run build_runner build --delete-conflicting-outputs

jadx-gui 打开apk分析工具

flutter 升级相关第三方类库后 编译失败 报找不到符号 清空编译缓存：
./flutterw clean
./flutterw pub get
cd android
./gradlew clean

项目结构：
lib下面的app模块是本app业务相关的模块
lib 下面除了app之外的其他模块，是所有项目的通用框架模块
http http网络请求
skin 换肤相关
util 工具类模块
widget 自定义UI组建模块
navigator 导航相关模块
依赖关系，lib下的app模块依赖依赖其他模块，但是其他模块不能依赖app模块
以后其他模

激活：get_cli
dart pub global activate get_cli
初始化项目：get init
创建模块: get create page:home

