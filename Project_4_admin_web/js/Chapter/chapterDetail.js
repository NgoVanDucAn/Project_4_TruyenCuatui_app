var token = localStorage.getItem('token');
console.log(token);
var refreshToken = localStorage.getItem('refreshToken');


$(document).ready(function() {

    // Kiểm tra đăng nhập
  if (!localStorage.getItem('isLoggedIn') || localStorage.getItem('isLoggedIn') !== 'true') {
    // Người dùng không đăng nhập, chuyển hướng đến trang đăng nhập
    window.location.href = 'index.html';
  }
    const urlParams = new URLSearchParams(window.location.search);
    const ChapterId = urlParams.get('chapter_id');

    // Sử dụng id để thực hiện các xử lý tương ứng (ví dụ: gọi API để lấy thông tin )
    fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetDetailPagesWithChapterId/${ChapterId}`,{
        headers: {
            // 'Authorization': 'Bearer ' + token
          }
    })
    .then(response => {
        if (response.status === 401) {
            // Nếu mã trạng thái là 401, gửi yêu cầu đến server để làm mới token
            return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Auth/refreshToken', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    // 'Authorization': 'Bearer ' + token
                    
                },
                body: JSON.stringify({
                    accessToken: token,
                    refreshToken: refreshToken
                })
            })
            .then(response => response.json())
            .then(data => {
                // Lưu lại token mới và refreshToken (nếu có)
                localStorage.setItem('token', data.accessToken);
                if (data.refreshToken) {
                    localStorage.setItem('refreshToken', data.refreshToken);
                    console.log(data.refreshToken);
                }
                // Thực hiện lại yêu cầu fetch
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetDetailPagesWithChapterId/${ChapterId}`, {
                    headers: {
                        // 'Authorization': 'Bearer ' + data.accessToken
                    }
                }).then(response => response.json());
            });
        } else {
            return response.json();
        }
    })
    .then(data => {
        var CateNameElement = document.getElementById('name');
        var CateContentElement = document.getElementById('Content');
        var CateImageElement = document.getElementById('Pages');
        
        var backButton = document.getElementById('back-to-detail');
        var defaultHref = 'detail-story.html?story_id=' + data[0].storyIdChapter;

        if (!backButton.getAttribute('href')) {
        backButton.setAttribute('href', defaultHref);
        }


        CateNameElement.innerText = data[0].chapterName;
        CateContentElement.innerText = data[0].chapterContent;
        CateImageElement.innerHTML = '';

        data[0].pages.forEach(p => {
            // var image =
            var imagePage = '<div>'+
            
                                '<picture>'+
                                    '<source media="(min-width:465px)" srcset="'+ p.images +'">'+
                                    '<style> @media (max-width: 465px) { picture img { width: 100%; height: auto; } }'+
                                    '</style>'+
                                    '<img src="' + p.images +'" style="max-width: 550px; max-height: 620px;">'+
                                '</picture>'+
                            '</div>'
            CateImageElement.innerHTML += imagePage;          
        });;

       

    });
});