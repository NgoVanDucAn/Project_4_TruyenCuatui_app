using Project4.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Project4.Controllers
{
    [Route("api")]
    [ApiController]
    public class UsersController : Controller
    {
        protected readonly UserManager<CustomUser> _userManager;
        protected readonly RoleManager<IdentityRole> _roleManager;
        protected readonly IHttpContextAccessor _contextAccessor;
        public UsersController(IHttpContextAccessor contextAccessor, UserManager<CustomUser> userManager, RoleManager<IdentityRole> roleManager)
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _contextAccessor = contextAccessor;
        }
        [HttpGet]
        [Route("[controller]/[action]")]
        public async Task<IActionResult> Index()
        {
            var users = _userManager.Users.ToList();
            return Ok(users);
        }
    }
}
