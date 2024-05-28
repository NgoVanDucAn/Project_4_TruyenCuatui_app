import { useEffect } from 'react';

function Dashboard() {
  useEffect(() => {
    const token = localStorage.getItem('token');
    const refreshToken = localStorage.getItem('refreshToken');

    // Kiểm tra đăng nhập
    if (!localStorage.getItem('isLoggedIn') || localStorage.getItem('isLoggedIn') !== 'true') {
      // Người dùng không đăng nhập, chuyển hướng đến trang đăng nhập
      window.location.href = 'signin.html';
    }

    // Lấy danh sách Category
    fetch('http://192.168.0.101:5111/api/Categories/GetAll', {
      headers: {
        'Authorization': 'Bearer ' + token
      }
    })
      .then(response => {
        if (response.status === 401) {
          // Nếu mã trạng thái là 401, gửi yêu cầu đến server để làm mới token
          return fetch('http://192.168.0.101:5111/api/Auth/refreshToken', {
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
              }
              // Thực hiện lại yêu cầu fetch
              return fetch('http://192.168.0.101:5111/api/Categories/GetAll', {
                headers: {
                  'Authorization': 'Bearer ' + data.accessToken
                }
              });
            });
        } else {
          return response.json();
        }
      })
      .then(data => {
        // Xử lý dữ liệu danh sách Category
        var resultContainer = document.getElementById('categories');
        resultContainer.innerHTML = ''; // Xóa nội dung cũ
        var slicedData = data.slice(0, 4); // Lấy 4 phần tử đầu tiên
        slicedData.forEach(category => {
          var categoryElement = document.createElement('div');
          categoryElement.classList.add('w-100', 'align-items-center', 'justify-content-between');
          categoryElement.innerHTML = '<span>' + category.name + '</span>' + '<span>' + category.description + '</span>' + '<hr>';
          resultContainer.appendChild(categoryElement);
        });
      })
      .catch(error => console.log(error));

    // Lấy danh sách Stories
    fetch('http://192.168.0.101:5111/GetAllStories', {
      headers: {
        'Authorization': 'Bearer ' + token
      }
    })
      .then(response => {
        if (response.status === 401) {
          // Nếu mã trạng thái là 401, gửi yêu cầu đến server để làm mới token
          return fetch('http://192.168.0.101:5111/api/Auth/refreshToken', {
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
              }
              // Thực hiện lại yêu cầu fetch
              return fetch('http://http://192.168.0.101:5111/GetAllStories', {
                headers: {
                  'Authorization': 'Bearer ' + data.accessToken
                }
              });
            });
        } else {
          return response.json();
        }
      })
      .then(data => {
        // Xử lý dữ liệu danh sách Stories
        var resultContainer = document.querySelector('#listable tbody');
        // Sắp xếp mảng data theo thời gian cập nhật giảm dần
        data.sort((a, b) => new Date(b.updatedTime) - new Date(a.updatedTime));

        // Lấy 5 phần tử đầu tiên
        var latestData = data.slice(0, 5);
        resultContainer.innerHTML = ''; // Xóa nội dung cũ
        latestData.forEach(story => {
          var ifStatus = story.status ? 'Complete' : 'Ongoing';
          var row = '<tr>' +
            '<td><input class="form-check-input" type="checkbox"></td>' +
            '<td>' + story.id + '</td>' +
            '<td><image src="' + story.image + '" width="80" height="100" alt=""></td>' +
            '<td>' + story.name + '</td>' +
            '<td>' + story.author.userName + '</td>' +
            '<td>' + ifStatus + '</td>' +
            '<td>' + story.updatedTime + '</td>' +
            '<td>' + story.view + '</td>' +
            '<td><a class="btn btn-sm btn-success" href="detail-story.html?story_id=' + story.id + '">Detail</a></td>' +
            '</tr>';
          resultContainer.innerHTML += row;
        });
      });
  }, []);

  return (
    <div>
      <div id="categories"></div>
      <table id="listable">
        <tbody></tbody>
      </table>
    </div>
  );
}

export default Dashboard;