namespace Project4.DTO
{
    public class UserDTO
    {
        public String? userId { get; set; }
        public List<StoryUserDTO> Stories { get; set; }
    }
}
