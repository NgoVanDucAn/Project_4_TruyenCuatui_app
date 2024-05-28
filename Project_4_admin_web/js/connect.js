const restrictedForms = document.querySelectorAll('restricted-form');

// Xử lý sự kiện submit cho từng form
restrictedForms.forEach(form => {
  form.addEventListener('submit', function(event) {
    event.preventDefault(); // Chặn việc gửi form

    // Kiểm tra trạng thái đăng nhập (ví dụ: kiểm tra token)
    const token = localStorage.getItem('token');
    if (!token) {
      // Chưa đăng nhập, điều hướng đến form đăng nhập
      window.location.href ='signin.html';
    } else {
      // Đã đăng nhập, cho phép gửi form
      this.submit();
    }
  });
});