using Project4.Data;
using Project4.Models;
using Project4.Repository;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;


namespace Project4.Controllers
{
    public class ViewController : APIBaseController<Viewed>
    {
        private readonly ApplicationDbContext _context;
        private readonly IViewdRepository _viewdRepository;
        public ViewController(IBaseRepository<Viewed> repository, ApplicationDbContext context,  IViewdRepository viewdRepository) : base(repository)
        {

            _context = context;
            _viewdRepository = viewdRepository;
        }

        [HttpGet("TotalCountsOfChapters")]
        public IActionResult GetChapterViewCounts(string id)
        {
            var chapterViewCounts = _viewdRepository.GetChapterViewCounts(id);

            return Ok(chapterViewCounts);
        }

        [HttpGet("TotalCountsOfStories")]
        public IActionResult GetStoryViewCounts()
        {
            var storyViewCounts = _context.Chapters
                .Where(c => c.StoryId != null)
                .Select(c => new { c.StoryId, ChapterId = c.Id })
                .ToList()
                .GroupBy(c => c.StoryId)
                .Select(g => new {
                    StoryId = g.Key,
                    ViewCount = g.Sum(d => _context.Vieweds.Count(v => v.ChapterId == d.ChapterId))
                }).ToList();

            return Ok(storyViewCounts);
        }

    }
}
