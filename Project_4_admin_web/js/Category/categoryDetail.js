
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
     //thuc hien lay thong tin cua 1 category bang id
    const urlParams = new URLSearchParams(window.location.search);
    const categoryId = urlParams.get('category_id');

    // Sử dụng category_id để thực hiện các xử lý tương ứng (ví dụ: gọi API để lấy thông tin category)
    fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetById?Id=${categoryId}`,{
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
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetById?Id=${categoryId}`, {
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
        // Xử lý dữ liệu trả về từ API (ví dụ: hiển thị thông tin category trong form)
            var CateId = document.getElementById('Id');
            CateId.value = data.id;
            var CateName = document.getElementById('Name');
            CateName.value = data.name;
            var textarea = document.getElementById('floatingTextarea');
            textarea.value = data.description;
            // textarea.innerText = data.description;
        })
        .catch(error => console.log(error));


    

    fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/GetDetailStoriesWithCategoryId/${categoryId}`,{
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
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/GetDetailStoriesWithCategoryId/${categoryId}`, {
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

            var currentPage = 1; // Trang hiện tại
            var itemsPerPage = 5; // Số lượng phần tử trên mỗi trang

            var StorySelect = document.getElementById('mySelect2');
            var resultContainer = document.querySelector('#stories tbody');

            // Hàm hiển thị các phần tử của trang hiện tại
            function displayPageItems(pageItems) {
            resultContainer.innerHTML = ''; // Xóa nội dung cũ
                    pageItems.forEach(story => {
                        story.stories.forEach(p => { 
                            var row = '<tr>' +
                            '<td><input class="form-check-input" type="checkbox"></td>' +
                            '<td>' + p.id + '</td>' +
                            '<td><image src="' + p.image + '" width="80" height="100" alt=""></td>' +
                            '<td>' + p.name + '</td>' +
                            '<td>' + p.subName + '</td>' +
                            '<td>' + p.description + '</td>' +
                        
                            '<td><a class="btn btn-sm btn-success" href="detail-story.html?story_id='+ p.id + '">Detail</a></td>' +
                            '</tr>';
                            resultContainer.innerHTML += row;
                        });
                        
                    }); 
            }
            
            // Hàm thay đổi trang
            function changePage(page) {
                currentPage = page;
                var startIndex = (currentPage - 1) * itemsPerPage;
                var endIndex = startIndex + itemsPerPage;
                var pageItems = data.slice(startIndex, endIndex);
                displayPageItems(pageItems);
                }
        
                // Sự kiện thay đổi trang
                StorySelect.addEventListener('change', function() {
                    var selectedValue = this.value;
        
                    // Sắp xếp danh sách dựa trên giá trị đã chọn
                    if (selectedValue === 'a-z') {

                        data[0].stories.sort((a, b) => a.name.localeCompare(b.name)); // Sắp xếp từ A-Z
                    } else if (selectedValue === 'z-a') {
                        data[0].stories.sort((a, b) => b.name.localeCompare(a.name)); // Sắp xếp từ Z-A
                    }
            
                    changePage(1); // Hiển thị trang đầu tiên
                });
        
                // Hàm tạo phân trang
                function createPagination() {
                    var totalPages = Math.ceil(data.length / itemsPerPage);
        
                    var paginationContainer = document.querySelector('paginationStories');
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


    //Lắng nghe sự kiện khi người dùng nhấn nút Lưu
    var submitButton = document.getElementById('submitButton');
    submitButton.addEventListener('click', function() {
        // Lấy giá trị mới từ các trường dữ liệu
        var newId = document.getElementById('Id').value;
        var newName = document.getElementById('Name').value;
        var newDescription = document.getElementById('floatingTextarea').value;

        // Gửi yêu cầu API để cập nhật dữ liệu category
        fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Update`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                 'Authorization': 'Bearer ' + token
                
            },
            body: JSON.stringify({
                id: newId,
                name: newName,
                description: newDescription
            })
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
                    token = data.accessToken
                    localStorage.setItem('token', token);
                    
                    if (data.refreshToken) {
                        refreshToken = data.refreshToken;
                        localStorage.setItem('refreshToken', refreshToken);
                        console.log(data.refreshToken);
                    }
                    // Thực hiện lại yêu cầu fetch
                    return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/Update`, {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ' + token
                            
                        },
                        body: JSON.stringify({
                            id: newId,
                            name: newName,
                            description: newDescription
                        })
                    }).then(response => response.json());
                });
            } else {
                return response.json();
            }
        })
        .then(updatedData => {
        // Xử lý dữ liệu trả về từ API sau khi cập nhật thành công
        console.log('Dữ liệu đã được cập nhật:', updatedData);
        window.location.href = 'detail-cate.html?category_id=' + updatedData.id;
        // Thực hiện các thao tác khác sau khi cập nhật dữ liệu thành công
        })
        .catch(error => console.log(error));
    });

});