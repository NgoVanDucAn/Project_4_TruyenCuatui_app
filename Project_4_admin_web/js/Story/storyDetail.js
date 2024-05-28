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
    const StoryId = urlParams.get('story_id');

    // Sử dụng id để thực hiện các xử lý tương ứng (ví dụ: gọi API để lấy thông tin )
    fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetStoryById?Id=${StoryId}`,{
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
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetStoryById?Id=${StoryId}`, {
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
        var StoryIdElement = document.getElementById('id');
        var StoryImageElement = document.getElementById('image');
        var StoryNameElement = document.getElementById('name');
        var StorySubNameElement = document.getElementById('subName');
        var createdUserElement = document.getElementById('createdUser');
        var StoryViewElement = document.getElementById('View');
        var StoryStatusElement = document.getElementById('status');
        var StoryCreatedTimeElement = document.getElementById('createdTime');
        var descriptionElement = document.getElementById('description');
        var categoriesElement = document.getElementById('Category');

        StoryIdElement.innerText = data.id;
        StoryImageElement.src = data.image;
        StoryNameElement.innerText = data.name;
        StorySubNameElement.innerText = data.subName || "N/A";
        createdUserElement.innerText = data.author.userName || "N/A";
        StoryViewElement.innerText = data.view;
        StoryStatusElement.innerText = data.status ? 'Complete' : 'Ongoing';
        StoryCreatedTimeElement.innerText = data.createdTime || "N/A";
        descriptionElement.innerText = data.description || "N/A";

        
        var categoriesHtml = "";
        data.storyCategory.forEach(cate => {
            categoriesHtml += '<a href="detail-cate.html?category_id=' + cate.cateId + '">'+ cate.cateName+'</a> | ';
            
            
        });
        categoriesElement.innerHTML = categoriesHtml;
       
    })
    .catch(error => console.log(error));

    
    fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetDetailChaptersWithStoryId/${StoryId}`,{
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
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetDetailChaptersWithStoryId/${StoryId}`, {
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

            var currentPage = 1; // Trang hiện tại
            var itemsPerPage = 5; // Số lượng phần tử trên mỗi trang

            var StorySelect = document.getElementById('mySelect');
            var resultContainer = document.querySelector('#storiesChapter tbody');
            
            

            // Hàm hiển thị các phần tử của trang hiện tại
            function displayPageItems(pageItems) {
            resultContainer.innerHTML = ''; // Xóa nội dung cũ
                pageItems.forEach(p => {
                    var ifTime = p.createdTime;
                    if(ifTime == null){
                        ifTime = "N/A"
                    }
                            var row = '<tr>' +
                            '<td><input class="form-check-input" type="checkbox"></td>' +
                            '<td>' + p.id + '</td>' +
                            '<td>' + p.name + '</td>' +
                            '<td>' + p.subName + '</td>' +
                            '<td>' + ifTime + '</td>' +
                            '<td>' + p.view + '</td>' +
                            '<td>' + p.isPay + '</td>' +
                            '<td><a class="btn btn-sm btn-success" href="detail-chapter.html?chapter_id='+ p.id + '">Detail</a></td>' +
                            '<td><a class="btn btn-sm btn-danger" href=""' + '>Delete</a></td>' +
                            '</tr>';
                            resultContainer.innerHTML += row;
                        
                        
                    }); 
            }
                

            // Hàm thay đổi trang
            function changePage(page) {
                currentPage = page;
                var startIndex = (currentPage - 1) * itemsPerPage;
                var endIndex = startIndex + itemsPerPage;
                var pageItems = data[0].chapters.slice(startIndex, endIndex);
                displayPageItems(pageItems);
                }
        
                // Sự kiện thay đổi trang
                StorySelect.addEventListener('change', function() {
                    var selectedValue = this.value;
        
                    // Sắp xếp danh sách dựa trên giá trị đã chọn
                    if (selectedValue === 'a-z') {

                        data[0].chapters.sort((a, b) => a.name.localeCompare(b.name)); // Sắp xếp từ A-Z
                    } else if (selectedValue === 'z-a') {
                        data[0].chapters.sort((a, b) => b.name.localeCompare(a.name)); // Sắp xếp từ Z-A
                    }
            
                    changePage(1); // Hiển thị trang đầu tiên
                });
        
                // Hàm tạo phân trang
                function createPagination() {
                    var totalPages = Math.ceil(data[0].chapters.length / itemsPerPage);
        
                    var paginationContainer = document.querySelector('.pagination');
                    paginationContainer.innerHTML = ''; // Xóa nội dung cũ
        
                    for (var i = 1; i <= totalPages; i++) {
                        var listItem = document.createElement('li');
                        var link = document.createElement('a');
                        link.href = '#';
                        link.textContent = i;
                        listItem.appendChild(link);
                        paginationContainer.appendChild(listItem);
            
                        link.addEventListener('click', function() {
                            var page = parseInt(this.textContent);
                            changePage(page);
                        });
                    }
                }
                // Hiển thị trang đầu tiên khi trang web được tải
                changePage(1);
                createPagination();
        
            })
            .catch(error => console.log(error));
    
});
