
$(document).ready(function() {
    $('#loginForm').submit(function(event) {
      event.preventDefault();
  
      var email = $('#email').val();
      var password = $('#password').val();

      var loginData = {
        email: email,
        password: password
      };
      
      fetch('http://example-env.eba-bsapjicf.us-east-1.elasticbeanstalk.com/api/Auth/doLogin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(loginData)
        
      })
      .then(response => response.json())
      .then(data => {
        // Xử lý phản hồi từ API
        if (data.result == true) {
          // Đăng nhập thành công
          $('#resultContainer').text('Login successful');
          // Lấy token từ phản hồi và lưu vào biến token

          var accessToken = data.accessToken
          var refreshToken = data.refreshToken
          localStorage.setItem('refreshToken', refreshToken);
          localStorage.setItem('token', accessToken);
          // Lưu trạng thái đăng nhập (nếu cần thiết)
          localStorage.setItem('isLoggedIn', true);
          window.location.href = 'users-manager.html';
          console.log('Done');  
          
        } else {
          // Đăng nhập thất bại
          $('#resultContainer').text('Login failed: ' + data.errors[0]);
          // Xóa trạng thái đăng nhập (nếu cần thiết)
          localStorage.removeItem('isLoggedIn');
        }
      })
      .catch(error => {
        console.error('An error occurred:', error);
        $('#resultContainer').text('An error occurred while processing your request');
      });
    });
  });

  $('#logoutButton').click(function() {
    logout();
  });
  function logout() {
    // Xóa token và thông tin đăng nhập từ localStorage
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('isLoggedIn');
    
    // Chuyển hướng người dùng đến trang đăng nhập
    window.location.href = 'index.html';
  }