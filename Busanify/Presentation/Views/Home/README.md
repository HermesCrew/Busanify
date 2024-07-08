1. https://developers.kakao.com/ 에 앱이 이미 등록되어 있다고 가정
**내 애플리케이션**에서 등록된 앱 -> 네이티브 앱 키 잘 복사해 두고
    
2. 
    - XCode에서 File 
     - Add Package Dependencies... 
    - 검색하는 곳에 https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM 입력 
    - kakaomapssdk-spm 선택하고 Add to Project에 생성한 프로젝트 선택하고 Add Package
    - Add to Target에 None 선택하고 Add Package 실행
    
3. 
    - terminal에서 프로젝트 디렉토리 경로로 이동
    - ```$ cd 디렉토리 경로(이동할 디렉토리 터미널로 드래그 해도 됨)```
    - pod install 실행(정상적으로 돌아가면 시간이 좀 오래걸림!)
    - 새로 생성된 *.xcworkspace 파일 실행
    - AppDelegate 파일에서
    ```Swift
    import KakaoMapsSDK // 이건 맨 위에

    // 아래 SDKInit... 이거만 붙여넣기
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SDKInitializer.InitSDK(appKey: "API_KEY")
        return true
    }
    ```
    
<details>
    <summary style="font-size: 25px;">만약 pod install 이 실행이 안되면</summary>
    
- CocoaPod이 설치되지 않았기 때문에 설치해야함
- 터미널에서 ```sudo gem install cocoapods``` 으로 설치
- 만약 위에도 안된다?
- https://brew.sh/ko/ 로 이동해서 brew를 설치-
- 다시 터미널로 돌아와서 ```brew install cocoapods``` 을 입력해서 설치
- 이것마저 안된다?
- 터미널에서 ```brew install rbenv``` 설치 후 완료되면
- ```rbenv install -l``` 입력해서 x.x.x형식으로 된것 중 제일 높은거 ```rbenv install 3.3.2``` 로 설치(24.6.24 기준 3.3.2)
- ```ruby -v``` 를 입력해서 잘 설치가 됐는지 확인
-  ```rbenv versions``` 을 입력했을 때 *표시가 설치한 버전이 아니라 system에 있으면
-  ```rbenv global 3.3.2``` 을 입력해서 버전을 변경
-  다시 ```rbenv versions``` 으로 잘 변경됐는지 확인
-  터미널에 ```vi ~/.zshrc\n\n[[ -d ~/.rbenv  ]] && \\n  export PATH=${HOME}/.rbenv/bin:${PATH} && \\n  eval "$(rbenv init -)"```  터미널에 입력해서 환경변수 설정
-  ```source ~/.zshrc``` 입력해서 저장
-  ```gem install bundler``` 입력
-  ```gem update --system 3.5.11``` 입력으로 뭔가 업데이트
-  ```sudo gem install cocoapods``` 으로 cocoapods설치
-  여기서 또 안되면 모르겠습니다..
-  만약 잘 넘어갔다면 다시 ```pod install``` 실행
</details>
