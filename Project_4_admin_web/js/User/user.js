// Lấy tham chiếu đến bảng và tbody


var token = localStorage.getItem('token');
console.log(token);

var refreshTokens = localStorage.getItem('refreshToken');
console.log(refreshTokens);

document.addEventListener('DOMContentLoaded', function () {
    const table = document.querySelector('.table');
    const tbody = table.querySelector('tbody');
    // Kiểm tra đăng nhập
    if (!localStorage.getItem('isLoggedIn') || localStorage.getItem('isLoggedIn') !== 'true') {
        // Người dùng không đăng nhập, chuyển hướng đến trang đăng nhập
        window.location.href = 'index.html';
    };
    // Fetch API và đổ dữ liệu vào tbody
    fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Users/Index',{
        
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
                    refreshToken: refreshTokens
                })
            })
            .then(response => response.json())
            .then(data => {
                // Lưu lại token mới và refreshToken (nếu có)
                token = data.accessToken
                localStorage.setItem('token', token);
                if (data.refreshToken) {
                    refreshTokens = data.refreshToken;
                    localStorage.setItem('refreshToken', refreshTokens);
                    console.log(data.refreshToken);
                }
                // Thực hiện lại yêu cầu fetch
                return fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Users/Index', {
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


        // Hàm hiển thị các phần tử của trang hiện tại
        function displayPageItems(pageItems) {
            // Xóa dòng loading trước khi đổ dữ liệu
            tbody.innerHTML = '';
            // Lặp qua danh sách người dùng và tạo các hàng trong tbody
            pageItems.forEach(user => {
                const row = document.createElement('tr');
                row.innerHTML = 
                    '<td><input class="form-check-input" type="checkbox"></td>' +
                    '<td>'+ user.id + '</td>'+
                    '<td>'+ user.userName +'</td>'+
                    '<td>'+user.dateOfBirth+'</td>'+
                    '<td>'+'<a class="btn btn-sm btn-success"' + 
                    'href="detail-user.html?user_id='+ encodeURIComponent(user.id) + '">Detail</a></td>';
                
                tbody.appendChild(row);
            });
        }
        // Lấy tham chiếu đến ô tìm kiếm
        var searchInput = document.getElementById('searchInput');

        // Lắng nghe sự kiện khi người dùng nhập vào ô tìm kiếm
        searchInput.addEventListener('input', function() {
            var searchTerm = searchInput.value.toLowerCase(); // Lấy giá trị tìm kiếm và chuyển thành chữ thường

            // Lọc và hiển thị các mục phù hợp với từ khóa tìm kiếm
            var filteredItems = data.filter(function(user) {
                return user.userName.toLowerCase().includes(searchTerm);
            });
            
            displayPageItems(filteredItems); // Hiển thị các mục đã lọc
        });


        // Hàm thay đổi trang
        function changePage(page) {
        currentPage = page;
        var startIndex = (currentPage - 1) * itemsPerPage;
        var endIndex = startIndex + itemsPerPage;
        var pageItems = data.slice(startIndex, endIndex);
        displayPageItems(pageItems);
        }

        var CateSelect = document.getElementById('mySelect');
        // Sự kiện thay đổi trang
        CateSelect.addEventListener('change', function() {
            var selectedValue = this.value;

            // Sắp xếp danh sách dựa trên giá trị đã chọn
            if (selectedValue === 'apple') {
                data.sort((a, b) => a.userName.localeCompare(b.userName)); // Sắp xếp từ A-Z
            } else if (selectedValue === 'banana') {
                data.sort((a, b) => b.userName.localeCompare(a.userName)); // Sắp xếp từ Z-A
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

})