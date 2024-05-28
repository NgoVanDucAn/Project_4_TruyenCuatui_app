let userRoles = [];
let allRoles = [];
const urlParams = new URLSearchParams(window.location.search);
const userId = urlParams.get('user_id');

var token = localStorage.getItem('token');
console.log(token);
var refreshTokens = localStorage.getItem('refreshToken');
console.log(refreshTokens);

function createCheckbox(role, isChecked) {
    const checkboxWrapper = document.createElement('div');
    checkboxWrapper.className = 'form-check';

    const checkbox = document.createElement('input');
    checkbox.className = 'rolesCheckboxList';
    checkbox.type = 'checkbox';
    checkbox.value = role.name;
    checkbox.id = `checkbox_${role}`;
    checkbox.checked = isChecked; // Gán giá trị isChecked cho thuộc tính checked

    const label = document.createElement('label');
    label.className = 'form-check-label';
    label.htmlFor = `checkbox_${role}`;
    label.innerText = role;

    checkboxWrapper.appendChild(checkbox);
    checkboxWrapper.appendChild(label);

    return checkboxWrapper;
}

// Hàm hiển thị vai trò
function displayRoles(userRoles, allRoles) {
    const rolesCheckboxList = document.getElementById('rolesCheckboxList');
    rolesCheckboxList.innerHTML = '';

    allRoles.forEach(role => {
        const isChecked = userRoles.includes(role.name);
        const checkbox = createCheckbox(role.name, isChecked);
        rolesCheckboxList.appendChild(checkbox);
    });
}
document.addEventListener('DOMContentLoaded', function() {
  
       
        // Xử lý sự kiện khi nhấn nút Update
        const submitButton = document.getElementById('submitButton');
        const rolesCheckboxList = document.querySelectorAll('#rolesCheckboxList');

        submitButton.addEventListener('click', function() {
        // Tạo một mảng để lưu trữ các vai trò đã chọn
        const selectedRoles = [];

        // Lặp qua các checkbox để kiểm tra vai trò nào đã được chọn
        rolesCheckboxList.forEach(checkbox => {
            console.log(checkbox, checkbox?.checked)
            if (checkbox?.checked) {
            // Thêm tên vai trò đã chọn vào mảng
            selectedRoles.push(checkbox.value);
            
            }
        });

        console.log(selectedRoles);
        // Gửi yêu cầu cập nhật thông qua API
        const apiUrl = `http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Users/DoUpdateRoll?userId=${userId}`;

        // Tạo yêu cầu HTTP POST sử dụng Fetch API
        fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token
                
            },
            body: JSON.stringify(selectedRoles)
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
                    return fetch(apiUrl, {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ' + token
                            
                        },
                        body: JSON.stringify(selectedRoles)
                    }).then(response => response.json())
                    .then(updatedData => {
                        
                    // Xử lý dữ liệu trả về từ API sau khi cập nhật thành công
                    alert('Done');
                    console.log('Dữ liệu đã được cập nhật:', updatedData);
                    window.location.href = 'detail-user.html?user_id=' + userId;
                    // Thực hiện các thao tác khác sau khi cập nhật dữ liệu thành công
                    })


                });
            } else {
                return response.json();
            }
            })
        .catch(error => {
            // Xử lý lỗi trong quá trình gửi yêu cầu
            console.error('Lỗi kết nối:', error);
        });
        });
    });



// Lấy danh sách vai trò và vai trò của người dùng từ API khi trang được tải
window.addEventListener('DOMContentLoaded', () => {
    fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Users/UpdateRoll/${userId}`,{
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
                console.log(data.token);
                if (data.refreshToken) {
                    refreshTokens = data.refreshToken;
                    localStorage.setItem('refreshToken', refreshTokens);
                    console.log(data.refreshToken);
                }
                // Thực hiện lại yêu cầu fetch
                return fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Users/UpdateRoll/${userId}`, {
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
            userRoles = data.usersRole;
            allRoles = data.listRoles;
            displayRoles(userRoles, allRoles);
        
        })
        .catch(error => console.log('Error:', error));


        fetch(`http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/GetDetailStoriesWithUserId/${userId}`,{
            headers: {
                // 'Authorization': 'Bearer ' + token
              }
        })
        .then(response => response.json())
        .then(data => {
            var UserIdElement = document.getElementById('UserId');
            var UserImageElement = document.getElementById('image');
            var UserNameElement = document.getElementById('UserName');
            var UserGenderElement = document.getElementById('gender');
            var DateOfBirthElement = document.getElementById('dateOfBirth');
        
            UserIdElement.innerText = data.userId;
            UserNameElement.innerText = data.email;
        
            var gender = data.gender;
            if (gender === 0) {
                UserGenderElement.innerText = 'Male';
                UserImageElement.src = '../img/user.jpg';
            } else {
                UserGenderElement.innerText = 'Female';
                UserImageElement.src = '../img/user.jpg';
            }
        
            DateOfBirthElement.innerText = data.dateOfBirth || 'N/A';



            // var currentPage = 1; // Trang hiện tại
            // var itemsPerPage = 5; // Số lượng phần tử trên mỗi trang

            // var StorySelect = document.getElementById('mySelect');
            // var resultContainer = document.querySelector('#stories tbody');

            // // Hàm hiển thị các phần tử của trang hiện tại
            // function displayPageItems(pageItems) {
            // resultContainer.innerHTML = ''; // Xóa nội dung cũ
            //         pageItems.forEach(story => {
            //             story.stories.forEach(p => { 
            //                 var row = '<tr>' +
            //                 '<td><input class="form-check-input" type="checkbox"></td>' +
            //                 '<td>' + p.id + '</td>' +
            //                 '<td><image src="' + p.image + '" width="80" height="100" alt=""></td>' +
            //                 '<td>' + p.name + '</td>' +
            //                 '<td>' + p.subName + '</td>' +
            //                 '<td>' + p.description + '</td>' +
                        
            //                 '<td><a class="btn btn-sm btn-success" href="detail-story.html?story_id='+ p.id + '">Detail</a></td>' +
            //                 '</tr>';
            //                 resultContainer.innerHTML += row;
            //             });
                        
            //         }); 
            // }
            
            // // Hàm thay đổi trang
            // function changePage(page) {
            //     currentPage = page;
            //     var startIndex = (currentPage - 1) * itemsPerPage;
            //     var endIndex = startIndex + itemsPerPage;
            //     var pageItems = data.slice(startIndex, endIndex);
            //     displayPageItems(pageItems);
            //     }
        
            //     // Sự kiện thay đổi trang
            //     StorySelect.addEventListener('change', function() {
            //         var selectedValue = this.value;
        
            //         // Sắp xếp danh sách dựa trên giá trị đã chọn
            //         if (selectedValue === 'a-z') {

            //             data[0].stories.sort((a, b) => a.name.localeCompare(b.name)); // Sắp xếp từ A-Z
            //         } else if (selectedValue === 'z-a') {
            //             data[0].stories.sort((a, b) => b.name.localeCompare(a.name)); // Sắp xếp từ Z-A
            //         }
            
            //         changePage(1); // Hiển thị trang đầu tiên
            //     });
        
            //     // Hàm tạo phân trang
            //     function createPagination() {
            //         var totalPages = Math.ceil(data.length / itemsPerPage);
        
            //         var paginationContainer = document.querySelector('paginationStories');
            //         paginationContainer.innerHTML = ''; // Xóa nội dung cũ
        
            //         for (var i = 1; i <= totalPages; i++) {
            //             var listItem = document.createElement('li');
            //             var link = document.createElement('a');
            //             link.href = '#';
            //             link.textContent = i;
            //             listItem.appendChild(link);
            //             paginationContainer.appendChild(listItem);
            
            //             link.addEventListener('click', function() {
            //                 var page = parseInt(this.textContent);
            //                 changePage(page);
            //             });
            //         }
            //     }
            //     // Hiển thị trang đầu tiên khi trang web được tải
            //     changePage(1);
            //     createPagination();
        
        })
        .catch(error => console.log(error));
});