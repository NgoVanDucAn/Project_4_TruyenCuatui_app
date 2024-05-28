var token = localStorage.getItem('token');
console.log(token);
var refreshToken = localStorage.getItem('refreshToken');
console.log(refreshToken);

$(document).ready(function() {
    // Kiểm tra đăng nhập
  if (!localStorage.getItem('isLoggedIn') || localStorage.getItem('isLoggedIn') !== 'true') {
    // Người dùng không đăng nhập, chuyển hướng đến trang đăng nhập
    window.location.href = 'index.html';
  }
    fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetAllStories',{
        headers: {
            'Authorization': 'Bearer ' + token
          }
    })
    .then(response => {
        if (response.status === 401) {
            // Nếu mã trạng thái là 401, gửi yêu cầu đến server để làm mới token
            return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Auth/refreshToken', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + token
                    
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
                return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/GetAllStories', {
                    headers: {
                        'Authorization': 'Bearer ' + data.accessToken
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

            var CateSelect = document.getElementById('mySelect');
            var resultContainer = document.querySelector('#listable tbody');
            var subNames = data.subName;
            if(data.subName == null){
                subNames = "N/A";
            }
            // Hàm hiển thị các phần tử của trang hiện tại
            function displayPageItems(pageItems) {
            resultContainer.innerHTML = ''; // Xóa nội dung cũ
                    pageItems.forEach(story => {
                        var row = '<tr>' +
                        '<td><input class="form-check-input" type="checkbox"></td>' +
                        '<td>' + story.id + '</td>' +
                        '<td><image src="' + story.image + '" width="80" height="100" alt=""></td>' +
                        '<td>' + story.name + '</td>' +
                        '<td>' + subNames + '</td>' +
                        '<td>' + story.author.userName + '</td>' +
                        '<td>' + story.view + '</td>' +
                        '<td><a class="btn btn-sm btn-success" href="detail-story.html?story_id='+ story.id + '">Detail</a></td>' +
                        '<td><button class="btn btn-sm btn-danger" data-story-id="' + story.id + '">Delete</button></td>' +
                        '</tr>';
                        resultContainer.innerHTML += row;
                    }); 
                    var deleteButtons = document.querySelectorAll('.btn-danger');
                    deleteButtons.forEach(button => {
                        button.addEventListener('click', handleDeleteClick);
                    });
            }

            
            // Hàm xử lý sự kiện xóa
            function handleDeleteClick(event) {
                var storyId = event.target.dataset.storyId;
                
                // Gửi yêu cầu xóa storyId đến server và xử lý phản hồi từ server tại đây
                // Ví dụ:
                fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Story/Delete/' + storyId, {
                    method: 'DELETE',
                    headers: {
                        'Authorization': 'Bearer ' + token
                      }
                })
                .then(response => {
                    if (response.status === 401) {
                        // Nếu mã trạng thái là 401, gửi yêu cầu đến server để làm mới token
                        return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Auth/refreshToken', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer ' + token
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
                            return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Story/Delete/' + storyId, {
                                method: 'DELETE',
                                headers: {
                                    'Authorization': 'Bearer ' + token
                                  }
                            });
                        });
                    } else {
                        if (response.ok) {
                            // Xóa phần tử khỏi giao diện ngay sau khi xóa thành công
                            var confirmation = confirm('Bạn có chắc chắn muốn xóa danh mục này?');
                            if (confirmation) {
                                // Nếu người dùng xác nhận xóa
                                var row = event.target.closest('tr');
                                row.remove();
                                alert('Đã xóa thành công');
                                location.reload();
                            } else {
                                // Nếu người dùng không xác nhận xóa
                                alert('Hủy xóa');
                            }
                        } else {
                            console.log('Error deleting the category');
                            alert('error');
                        }
                    }
                    
                })
                .catch(error => {
                    console.log('Error deleting the story:', error);
                });
            }

            displayPageItems(data); // Hiển thị trang đầu tiên khi dữ liệu đã được tải
            // Hàm thay đổi trang
            function changePage(page) {
                currentPage = page;
                var startIndex = (currentPage - 1) * itemsPerPage;
                var endIndex = startIndex + itemsPerPage;
                var pageItems = data.slice(startIndex, endIndex);
                displayPageItems(pageItems);
                }
        
                var searchInput = document.getElementById('searchInput');

                // Lắng nghe sự kiện khi người dùng nhập vào ô tìm kiếm
                searchInput.addEventListener('input', function() {
                    var searchTerm = searchInput.value.toLowerCase(); // Lấy giá trị tìm kiếm và chuyển thành chữ thường

                    // Lọc và hiển thị các mục phù hợp với từ khóa tìm kiếm
                    var filteredItems = data.filter(function(category) {
                        return category.name.toLowerCase().includes(searchTerm);
                    });
                    
                    displayPageItems(filteredItems);
                    if(searchTerm = ''){
                        changePage(1);
                    } // Hiển thị các mục đã lọc
                });
                // Sự kiện thay đổi trang
                CateSelect.addEventListener('change', function() {
                    var selectedValue = this.value;
        
                    // Sắp xếp danh sách dựa trên giá trị đã chọn
                    if (selectedValue === 'apple') {
                        data.sort((a, b) => a.name.localeCompare(b.name)); // Sắp xếp từ A-Z
                    } else if (selectedValue === 'banana') {
                        data.sort((a, b) => b.name.localeCompare(a.name)); // Sắp xếp từ Z-A
                    }
            
                    changePage(1); // Hiển thị trang đầu tiên
                });
        
                // Hàm tạo phân trang
                function createPagination() {
                    var totalPages = Math.ceil(data.length / itemsPerPage);
        
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


             //thuc hien lay thong tin cua 1 category bang id
       
});
         
        
