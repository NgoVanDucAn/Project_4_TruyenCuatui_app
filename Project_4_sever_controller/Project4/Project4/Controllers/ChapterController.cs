using Project4.Data;
using Project4.DTO;
using Project4.Models;
using Project4.Repository;
using Project4.Response;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;

namespace Project4.Controllers
{
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme, Roles = "ADMIN")]
    public class ChapterController : Controller
    {
        private readonly IChapterRepository _chapterRepository;
        private readonly IPageRepository _pageRepository;
        private readonly ApplicationDbContext _context;
        public ChapterController(ApplicationDbContext context, IChapterRepository chapterRepository, IPageRepository pageRepository)
        {
            _chapterRepository = chapterRepository;
            _pageRepository = pageRepository;
            _context = context;
        }

        [HttpGet("GetChapterByName/{name}")]
        public async Task<ActionResult<Chapter>> GetChapterByName(string name)
        {
            var chapterDetail = await _chapterRepository.GetChapterByName(name);
            if (chapterDetail == null)
            {
                return NotFound();
            }
            return Ok(chapterDetail);
        }


        //-------------------------------------Add-Anh----------------------------------------------
        //[HttpPost("/UpAnhChapter")]

        //public async Task<string> UpS3([FromForm] ChapterDTO chapterDTO)
        //{
        //    int t = 0;
        //    if (chapterDTO == null)
        //    {
        //        return "Error ";
        //    }
        //    foreach (var image in chapterDTO.Images)
        //    {
        //        t++;
        //        Chapter chapter = new Chapter();
        //        chapter.Id = chapterDTO.ChapterId + "-" + t;
        //        chapter.Images = await _pageRepository.WritingAnObjectAsync(image) == "" ? "" : await _pageRepository.WritingAnObjectAsync(image);
        //        chapter.Content = chapterDTO.Content;
        //        chapter.StoryId = chapterDTO.StoryId;
        //        chapter.Name = chapterDTO.Name;
        //        chapter.SubName = chapterDTO.SubName;
        //        await _chapterRepository.CreateAsync(chapter);
        //    }
        //    return "ok roi";
        //}

        //----------------------------------------Update-Anh-------------------------------------------------
        //[HttpPut("/UpdateAnhChapter/{id}")]
        //public async Task<ActionResult<string>> UpdateChapter([FromForm] ChapterDTO chapterDTO, string id)
        //{
        //    if (chapterDTO == null)
        //    {
        //        return "Error: Input data is invalid.";
        //    }

        //    var existingChapter = await _context.Chapters.FindAsync(id);
        //    if (existingChapter == null)
        //    {
        //        return $"Error: No existing chapter found with ID {id}.";
        //    }

        //    if (!string.IsNullOrEmpty(existingChapter.Images))
        //    {
        //        await _chapterRepository.DeleteAsync(existingChapter.Images);
        //    }

        //    foreach (var image in chapterDTO.Images)
        //    {
        //        string imageResult = await _pageRepository.WritingAnObjectAsync(image);
        //        existingChapter.Images = string.IsNullOrEmpty(imageResult) ? "" : imageResult;
        //    }
        //    existingChapter.Name = chapterDTO.Name;
        //    existingChapter.SubName = chapterDTO.SubName;
        //    existingChapter.Content = chapterDTO.Content;
        //    existingChapter.StoryId = chapterDTO.StoryId;

        //    _context.Chapters.Update(existingChapter);
        //    await _context.SaveChangesAsync();

        //    return "ok roi";
        //}

        //------------------------------------List-Anh-------------------------------------------------------

        [HttpGet("/GetAllChapters")]
        public async Task<List<Chapter>> GetChapters()
        {
            List<Chapter> p = await _chapterRepository.GetAllAsync();
            List<Chapter> np = new List<Chapter>();
            String t = "";
            foreach (Chapter chapter in p)
            {
                Chapter ts = new Chapter();
                ts.Id = chapter.Id;
                //t = await _pageRepository.GetS3FilesImage(chapter.Images);
                ts.Name = chapter.Name;
                ts.SubName = chapter.SubName;
                ts.Content = chapter.Content;
                //ts.Images = t;
                ts.StoryId = chapter.StoryId;
                ts.IsPay = chapter.IsPay;
                np.Add(ts);
            }
            return np;
        }


        [HttpGet("GetDetailChaptersWithStoryId/{storyId}")]
        public async Task<ActionResult<ChapterStoryIdResponse>> GetDetailChaptersWithStoryId(string storyId)
        {
            var chapterDetail = await _chapterRepository.GetDetailChaptersWithStoryId(storyId);
            chapterDetail = await _chapterRepository.GetViewChapter(chapterDetail);
            if (chapterDetail == null)
            {
                return NotFound();
            }
            return Ok(chapterDetail);
        }
    }
}
