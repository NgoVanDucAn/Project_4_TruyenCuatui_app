namespace Project4.DTO
{
    public class ChapterDTO
    {
       
        public String? ChapterId { get; set; }
        public String? Name { get; set; }
        public String? SubName { get; set; }
        public String? Content { get; set; }
        public List<IFormFile>? Images { get; set; }
        public String? StoryId { get; set; }
        public bool? IsPay { get; set; }


    }
}
