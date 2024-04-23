利用社群形式來評鑑各個餐廳、景點． 

必要步驟：pod install 

如果需要使用上傳功能，必須將APIKey.plist的googleMapAPIKey設置，將GoogleService-Info.plist加入，  
不需要的話就直接把GoogleService-Info.plist移除．  

如果連不上Server，可以把Constant.swift裡面的getServerData設成false，去讀取本機的資料．  

如遇到Compile問題，可以檢查看看LocationPicker -> Target -> Build Setting -> User Script Sandboxing 要設成No

使用Demo影片 : https://www.youtube.com/watch?v=1-5QZEP4Pcg

如有更多問題可以mail : kevin20694569@gmail.com
