using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Project4.Data;
using Project4.Models;
using Project4.Repository;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;

namespace Project4.Controllers
{
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme, Roles = "ADMIN")]
    public class CategoriesController : APIBaseController<Category>
    {
        private readonly ICategoryRepository _categoryRepository;

        public CategoriesController(IBaseRepository<Category> repository,ICategoryRepository categoryRepository) : base(repository)
        {
            _categoryRepository = categoryRepository;
        }

        [HttpGet("GetCategoriesByName/{name}")]
        public async Task<ActionResult<Category>> GetCategoriesByName(string name)
        {
            var cateDetail = await _categoryRepository.GetCategoriesByName(name);
            if (cateDetail == null)
            {
                return NotFound();
            }
            return Ok(cateDetail);
        }



    }
}
