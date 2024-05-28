var token = localStorage.getItem('token');
console.log(token);
var refreshToken = localStorage.getItem('refreshToken');
console.log(refreshToken);

document.addEventListener('DOMContentLoaded', function () {

    // Kiểm tra đăng nhập
  if (!localStorage.getItem('isLoggedIn') || localStorage.getItem('isLoggedIn') !== 'true') {
    // Người dùng không đăng nhập, chuyển hướng đến trang đăng nhập
    window.location.href = 'index.html';
  }
    // Lấy danh sách Category
    fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetAll', {
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
                return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/GetAll', {
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

        var CateSelect = document.getElementById('mySelect');
        var resultContainer = document.querySelector('#listable tbody');

        // Hàm hiển thị các phần tử của trang hiện tại
        function displayPageItems(pageItems) {
            resultContainer.innerHTML = ''; // Xóa nội dung cũ
            pageItems.forEach(category => {
                var row = '<tr>' +
                '<td><input class="form-check-input" type="checkbox"></td>' +
                '<td>' + category.id + '</td>' +
                '<td>' + category.name + '</td>' +
                '<td>' + category.description + '</td>' +
                '<td><a class="btn btn-sm btn-success" href="detail-cate.html?category_id=' + category.id + '">Detail</a></td>' +
                '<td><button class="btn btn-sm btn-danger" data-category-id="' + category.id + '">Delete</button></td>' +
                '</tr>';
                resultContainer.innerHTML += row;
            });
            var deleteButtons = document.querySelectorAll('.btn-danger');
                    deleteButtons.forEach(button => {
                        button.addEventListener('click', handleDeleteClick);
                    });
        }

        // Lấy tham chiếu đến ô tìm kiếm
        var searchInput = document.getElementById('searchInput');

        // Lắng nghe sự kiện khi người dùng nhập vào ô tìm kiếm
        searchInput.addEventListener('input', function() {
            var searchTerm = searchInput.value.toLowerCase(); // Lấy giá trị tìm kiếm và chuyển thành chữ thường

            // Lọc và hiển thị các mục phù hợp với từ khóa tìm kiếm
            var filteredItems = data.filter(function(category) {
                return category.name.toLowerCase().includes(searchTerm);
            });
            
            displayPageItems(filteredItems); // Hiển thị các mục đã lọc
        });
        // Hàm xử lý sự kiện xóa
        function handleDeleteClick(event) {
            var categoryId = event.target.dataset.categoryId;
            
            // Gửi yêu cầu xóa storyId đến server và xử lý phản hồi từ server tại đây
            // Ví dụ:
            fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Delete/' + categoryId, {
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
                        return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Categories/Delete/' + categoryId, {
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
        //ket thuc lay danh sach    
        //thuc hien chuc nang sort theo a-z, z-a
    // var cate = document.getElementById('CateSelect');
        
});


function slugify(str) {
    var slug = str
      .toLowerCase() // Chuyển thành chữ thường
      .normalize("NFD") // Chuẩn hóa Unicode
      .replace(/[\u0300-\u036f]/g, "") // Loại bỏ dấu diễn đạt
      .replace(/[^a-z0-9]+/g, "-") // Thay thế các ký tự không phải là chữ cái và số bằng dấu gạch ngang
      .replace(/^-+|-+$/g, "") // Loại bỏ dấu gạch ngang đầu và cuối chuỗi
      .replace(/-+/g, "-"); // Loại bỏ dấu gạch ngang liên tiếp
    return slug; 
}   
document.addEventListener('DOMContentLoaded', function() {
  
    var submitButton = document.getElementById('submitButton');
    
      // Gắn sự kiện click vào nút Submit trong modal
      submitButton.addEventListener('click', function() {
        
        var newName = document.getElementById('NewName').value;
        var newDescription = document.getElementById('NewDescription').value;
        var newId = slugify(newName);

        // Kiểm tra nếu người dùng đã nhập thông tin
        if (newName && newDescription) {
          // Gửi yêu cầu API để tạo mới category
          fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Create', {
            method: 'POST',
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
                return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Create', {
                    method: 'POST',
                    headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + token
                    },
                    
                    body: JSON.stringify({
                    id: newId,
                    name: newName,
                    description: newDescription
                    })
                });
            });
            } else {
                return response.json();
            }
        
        }).then(createdData => {
            // Xử lý dữ liệu trả về từ API sau khi tạo mới thành công
            console.log('Category đã được tạo mới:', createdData);
            window.location.href = 'categories-manager.html';

            // Hiển thị thông báo cho người dùng
            alert('Category đã được thêm thành công!');

            // Thực hiện các thao tác khác sau khi tạo mới thành công
          })
          .catch(error => console.log(error));
        } else {
          // Hiển thị thông báo nếu người dùng không nhập đủ thông tin
          alert('Vui lòng nhập đủ thông tin category!');
        }
    });
});
 