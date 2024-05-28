
var categoryList = [0];
    document.addEventListener('DOMContentLoaded', function () {
        var token = localStorage.getItem('token');
    console.log(token);
    var refreshToken = localStorage.getItem('refreshToken');
    console.log(refreshToken);
    // Kiểm tra đăng nhập
  if (!localStorage.getItem('isLoggedIn') || localStorage.getItem('isLoggedIn') !== 'true') {
    // Người dùng không đăng nhập, chuyển hướng đến trang đăng nhập
    window.location.href = 'index.html';
  }
    // Lấy danh sách Category
    fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetAll',{
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
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetAll`, {
                    headers: {
                        // 'Authorization': 'Bearer ' + data.accessToken
                    }
                });
            });
        } else {
            return response.json();
        }
    })
        .then(data => {
            var resultContainer = $('#categories');
            resultContainer.empty(); // Xóa nội dung cũ
            var slicedData = data.slice(0, 4); // Lấy 4 phần tử đầu tiên
            slicedData.forEach(category => {
                var categoryElement = $('<div></div>');
                categoryElement.addClass('w-100', 'align-items-center', 'justify-content-between');
                categoryElement.html('<div>' + category.name + '</div>'+'<div>'+ category.description +'</div>'+'<hr>');
                resultContainer.append(categoryElement);
            });
        })
        .catch(error => console.log(error));
    //ket thuc lay danh sach 

    fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetAllStories',{
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
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetAllStories`, {
                    headers: {
                        // 'Authorization': 'Bearer ' + data.accessToken
                    }
                });
            });
        } else {
            return response.json();
        }
    })
        .then(data => {
            
            var resultContainer = document.querySelector('#listable tbody');
            // Sắp xếp mảng data theo thời gian cập nhật giảm dần
            data.sort((a, b) => new Date(b.updatedTime) - new Date(a.updatedTime));

            // Lấy 5 phần tử đầu tiên
            var latestData = data.slice(0, 5);
            resultContainer.innerHTML = ''; // Xóa nội dung cũ
            latestData.forEach(story => {
                var ifStatus = data.status ? 'Complete' : 'Ongoing';
                var row = '<tr>' +
                '<td><input class="form-check-input" type="checkbox"></td>' +
                '<td>' + story.id + '</td>' +
                '<td><image src="' + story.image + '" width="80" height="100" alt=""></td>' +
                '<td>' + story.name + '</td>' +
                '<td>' + story.author.userName + '</td>' +
                '<td>' + ifStatus + '</td>' +
                '<td>' + story.updatedTime + '</td>' +
                '<td>' + story.view + '</td>' +
                '<td><a class="btn btn-sm btn-success" href="detail-story.html?story_id='+ story.id + '">Detail</a></td>' +
                '</tr>';
                resultContainer.innerHTML += row;
            }); 
    });
});