namespace Project4.DTO
{
    public class StoryDTO
    {
        public String? Id { get; set; }
        public String? Name { get; set; }
        public String? SubName { get; set; }
        public String? Description { get; set; }
        public List<IFormFile>? Image { get; set;}
        public bool? Status { get;set; }

    }
}
