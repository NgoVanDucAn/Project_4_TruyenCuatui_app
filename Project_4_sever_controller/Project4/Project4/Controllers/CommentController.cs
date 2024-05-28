using Project4.DTO;
using Project4.Models;
using Project4.Repository;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Project4.Controllers
{
    public class CommentController : APIBaseController<Comment>
    {
        private readonly ICommentRepository _commentRepository;
        public CommentController(ICommentRepository commentRepository, IBaseRepository<Comment> repository) : base(repository)
        {
            _commentRepository = commentRepository;
        }

        [HttpGet("GetDetailCommentsWithUser/{userId}")]
        public async Task<ActionResult<UserCommentDTO>> GetDetailCommentsWithUser(string userId)
        {
            var commentDetail = await _commentRepository.GetDetailCommentsWithUser(userId);
            if (commentDetail == null)
            {
                return NotFound();
            }
            return Ok(commentDetail);
        }
        [HttpGet("GetCommentsByName/{name}")]
        public async Task<ActionResult<Comment>> GetCommentsByName(string name)
        {
            var commentDetail = await _commentRepository.GetCommentsByName(name);
            if (commentDetail == null)
            {
                return NotFound();
            }
            return Ok(commentDetail);
        }
    }
}
