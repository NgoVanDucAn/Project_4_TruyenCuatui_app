using Amazon.Runtime;
using Amazon.S3.Model;
using Amazon.S3;
using Project4.Models;
using Project4.Repository;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Amazon;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Project4.DTO;
using Microsoft.EntityFrameworkCore.Migrations;
using Project4.Data;
using Project4.Response;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;


namespace Project4.Controllers
{
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme, Roles = "ADMIN")]
    public class PagesController : Controller
    {
        private readonly IPageRepository _pageRepository;
        private readonly ApplicationDbContext _context;
        private readonly IChapterRepository _chapterRepository;

        public PagesController(IChapterRepository chapterRepository, ApplicationDbContext context, IBaseRepository<Pagee> repository, IPageRepository pageRepository)
        {
            _pageRepository = pageRepository;
            _context = context;
            _chapterRepository = chapterRepository;
        }
        //-------------------------------------Add-Anh----------------------------------------------
        [HttpPost("/UpAnh")]
        
        public async Task<string> UpS3([FromBody] PageeDTO pageDTO)
        {
            int t = 0;
            if (pageDTO == null)
            {
                return "Error ";
            }
            foreach (var image in pageDTO.Images)
            {
                t++;
                Pagee page = new Pagee();
                page.Id = pageDTO.PageId +"-" + t;
                page.Images = await _pageRepository.WritingAnObjectAsync(image) == "" ? "" : await _pageRepository.WritingAnObjectAsync(image);
                page.Content = pageDTO.Content;
                page.ChapterId = pageDTO.ChapterId;
                await _pageRepository.CreateAsync(page);
            }
            return "ok roi";
        }
        
        //----------------------------------------Update-Anh-------------------------------------------------
        [HttpPut("/UpdateAnh/{id}")]
        public async Task<ActionResult<string>> UpdatePagee([FromBody] PageeDTO pageDTO, string id)
        {
            if (pageDTO == null)
            {
                return "Error: Input data is invalid.";
            }

            foreach (var image in pageDTO.Images)
            {
                var existingPage = await _context.Pagees.FindAsync(id);
                if (existingPage == null)
                {
                    // Handle case where the record does not exist
                    return $"Error: No existing page found with ID {id}.";
                }

                if (!string.IsNullOrEmpty(existingPage.Images))
                {
                    await _pageRepository.DeleteAsync(existingPage.Images);
                }

                string imageResult = await _pageRepository.WritingAnObjectAsync(image);
                existingPage.Images = string.IsNullOrEmpty(imageResult) ? "" : imageResult;
                existingPage.Content = pageDTO.Content;
                existingPage.ChapterId = pageDTO.ChapterId;

                _context.Pagees.Update(existingPage);
                await _context.SaveChangesAsync();
            }

            return "ok roi";
        }

        //------------------------------------List-Anh-------------------------------------------------------

        [HttpGet("/GetAllPagee")]
        public async Task<List<Pagee>> GetPages()
        {
            List<Pagee> p = await _pageRepository.GetAllAsync();
            List<Pagee> np = new List<Pagee>();
            String t = "";
            foreach (Pagee page in p)
            {
                Pagee ts = new Pagee();
                t = await _pageRepository.GetS3FilesImage(page.Images);
                ts.ChapterId = page.ChapterId;
                ts.Images = t;
                ts.Id = page.Id;
                ts.Content = page.Content;
                np.Add(ts);
            }
            return np;
        }

        //-----------------------------------------Xoa-Anh----------------------------------------------
        [HttpDelete("/DeleteAnh/{id}")]
        public async Task<ActionResult<string>> DeletePagee(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return BadRequest("Invalid ID.");
            }

            var page = await _context.Pagees.FindAsync(id);
            if (page == null)
            {
                return NotFound($"No page found with ID {id}.");
            }

            if (!string.IsNullOrEmpty(page.Images))
            {
                await _pageRepository.DeleteAsync(page.Images);
            }

            _context.Pagees.Remove(page);
            await _context.SaveChangesAsync();

            return Ok("Page deleted successfully.");
        }


        //------------------------------------------Tim-Kim-Anh-Theo-Content-----------------------------------
        [HttpGet("GetPagesByContent/{content}")]
        public async Task<ActionResult<Pagee>> GetPagesByContent(string content)
        {
            var pageDetail = await _pageRepository.GetPagesByContent(content);
            if (pageDetail == null)
            {
                return NotFound();
            }
            return Ok(pageDetail);
        }

        [HttpGet("GetDetailPagesWithChapterId/{chapterId}")]
        public async Task<ActionResult<ChapterResponse>> GetDetailPagesWithChapterId(string chapterId)
        {
            var pageDetail = await _chapterRepository.GetDetailPagesWithChapterId(chapterId);
            var pageDetails = await _chapterRepository.GetLinkPagesWithChapterId(pageDetail);
            if (pageDetails == null)
            {
                return NotFound();
            }
            return Ok(pageDetails);
        }

        [HttpPost("CreatePages/{chapterId}")]
        public async Task<IActionResult> CreatePage(string chapterId, [FromBody] PageeDTO pageDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var chapterExists = await _context.Chapters.AnyAsync(c => c.Id == chapterId);
            if (!chapterExists)
            {
                return NotFound($"Chapter with ID {chapterId} not found.");
            }
            var page = new Pagee
            {
                ChapterId = chapterId,
                Content = pageDto.Content,
                Id = pageDto.PageId,
                //Images = pageDto.Images
            };

            var createdPage = await _pageRepository.CreatePage(page);
            return Ok(createdPage);
        }

        //[HttpPost("/UpAnhTheoId")]

        //public async Task<string> UpAnhTheoid([FromBody] PageeDTO pageDTO, string chapterId)
        //{
        //    int t = 0;
        //    if (pageDTO == null)
        //    {
        //        return "Error ";
        //    }
        //    foreach (var image in pageDTO.Images)
        //    {
        //        t++;
        //        Pagee page = new Pagee();
        //        page.Id = pageDTO.PageId + "-" + t;
        //        page.Images = await _pageRepository.WritingAnObjectAsync(image) == "" ? "" : await _pageRepository.WritingAnObjectAsync(image);
        //        page.Content = pageDTO.Content;
        //        page.ChapterId = pageDTO.ChapterId;
        //        await _pageRepository.CreateAsync(page);
        //    }
        //    return "ok roi";
        //}

    }
}