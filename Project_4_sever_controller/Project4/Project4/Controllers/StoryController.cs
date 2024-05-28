using Project4.Data;
using Project4.DTO;
using Project4.Models;
using Project4.Repository;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
//using NuGet.Protocol.Core.Types;
using System.Drawing.Text;
using static Amazon.S3.Util.S3EventNotification;

using Project4.Response;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;

namespace Project4.Controllers
{
    [Route("api")]
    [ApiController]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme, Roles = "ADMIN")]
    public class StoryController : APIBaseController<Story>
    {
        private readonly IStoryRepository _storyRepository;
        private readonly ICategoryRepository _categoryRepository;
        private readonly IPageRepository _pageRepository;
        private readonly ApplicationDbContext _context;
        protected readonly UserManager<CustomUser> _userManager;
        protected readonly string currentUserId = "";
        protected readonly IHttpContextAccessor _contextAccessor;
        public StoryController(ICategoryRepository categoryRepository, IStoryRepository storyRepository, UserManager<CustomUser> userManager, IHttpContextAccessor contextAccessor, ApplicationDbContext context, IPageRepository pageRepository) : base(storyRepository)
        {
             _storyRepository = storyRepository;
            _context = context;
            _pageRepository = pageRepository;
            _userManager = userManager;
            _contextAccessor = contextAccessor;
            _categoryRepository = categoryRepository;
            var currentUser = _userManager.GetUserAsync(_contextAccessor.HttpContext.User).GetAwaiter().GetResult();
            if (currentUser != null)
            {
                this.currentUserId = currentUser.Id;
            }
        }


        //-------------------------------------Add-Anh----------------------------------------------
        [HttpPost("/UpAnhStory")]

        public async Task<string> UpS3([FromBody] StoryDTO storyDTO)
        {
            int t = 0;
            if (storyDTO == null)
            {
                return "Error ";
            }
            foreach (var image in storyDTO.Image)
            {
                t++;
                Story story = new Story();
                story.Id = storyDTO.Id + "-" + t;
                story.Image = await _pageRepository.WritingAnObjectAsync(image) == "" ? "" : await _pageRepository.WritingAnObjectAsync(image);
                story.Name = storyDTO.Name;
                story.SubName = storyDTO.SubName;
                story.Description = storyDTO.Description;
                story.Status = storyDTO.Status;
                await _storyRepository.CreateAsync(story);
                story.UpdatedUser = currentUserId;
                story.UpdatedTime = DateTime.Now;
                story.IsDeleted = false;
            }
            return "ok roi";
        }

        //----------------------------------------Update-Anh-------------------------------------------------
        [HttpPut("/UpdateAnhStory/{id}")]
        public async Task<ActionResult<string>> UpdateStory(string id, [FromBody] StoryDTO storyDTO)
        {
            if (storyDTO == null)
            {
                return "Error: Input data is invalid.";
            }

            var existingStory = await _context.Stories.FindAsync(id);
            if (existingStory == null)
            {
                return $"Error: No existing story found with ID {id}.";
            }

            if (!string.IsNullOrEmpty(existingStory.Image))
            {
                await _storyRepository.DeleteAsync(existingStory.Image);
            }

            foreach (var image in storyDTO.Image)
            {
                string imageResult = await _pageRepository.WritingAnObjectAsync(image);
                existingStory.Image = string.IsNullOrEmpty(imageResult) ? "" : imageResult;
            }

            existingStory.Name = storyDTO.Name;
            existingStory.SubName = storyDTO.SubName;
            existingStory.Description = storyDTO.Description;
            existingStory.Status = storyDTO.Status;
            existingStory.UpdatedUser = currentUserId;
            existingStory.UpdatedTime = DateTime.Now;
            existingStory.IsDeleted = false;
            _context.Stories.Update(existingStory);
            await _context.SaveChangesAsync();

            return "ok roi";
        }


        //------------------------------------List-Anh-------------------------------------------------------

        [HttpGet("/GetAllStories")]
        public async Task<List<StoryResponse>> GetStories()
        {
            List<StoryResponse> p = await _storyRepository.GetAllStoies();
            p = await _storyRepository.GetAllStoriesView(p);
            return p;
           
        }

        [HttpGet("/GetStoryById")]
        public async Task<StoryResponse> GetStoriesById(String id)
        {
            StoryResponse p = await _storyRepository.GetStoiesById(id);
            p = await _storyRepository.GetOneStoriesView(p);
            return p;

        }
        //------------------------------------------------------------Xoa-Anh------------------------------------------------------------
        [HttpDelete("/DeleteAnhStory/{id}")]
        public async Task<ActionResult<string>> DeleteStory(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return BadRequest("Invalid ID.");
            }

            var Story = await _context.Stories.FindAsync(id);
            if (Story == null)
            {
                return NotFound($"No page found with ID {id}.");
            }

            if (!string.IsNullOrEmpty(Story.Image))
            {
                await _storyRepository.DeleteAsync(Story.Image);
            }

            _context.Stories.Remove(Story);
            await _context.SaveChangesAsync();

            return Ok("Page deleted successfully.");
        }



        [HttpGet("/GetStoriesByName/{name}")]
        public async Task<ActionResult<Story>> GetStoriesByName(string name)
        {
            var storyDetail = await _storyRepository.GetStoriesByName(name);
            if (storyDetail == null)
            {
                return NotFound();
            }
            return Ok(storyDetail);
        }

        [HttpGet("GetDetailStoriesWithCategoryId/{categoryId}")]
        public async Task<ActionResult<CategoryDTO>> GetDetailStoriesWithCategoryId(string categoryId)
        {
            var storyDetail = await _categoryRepository.GetDetailStoriesWithCategoryId(categoryId);
            var imageStories = await _categoryRepository.GetLinkPagesWithChapterId(storyDetail);
            if (imageStories == null)
            {
                return NotFound();
            }
            return Ok(imageStories);
        }

        [HttpGet("GetDetailStoriesWithUser/{userId}")]
        public async Task<ActionResult<UserDTO>> GetDetailStoriesWithUser(string userId)
        {
            var storyDetaill = await _storyRepository.GetDetailStoriesWithUserId(userId);
            var imageStoriess = await _storyRepository.GetLinkPictuersStoriesWithUserId(storyDetaill);
            if (storyDetaill == null)
            {
                return NotFound();
            }
            return Ok(storyDetaill);
        }


    }
}
