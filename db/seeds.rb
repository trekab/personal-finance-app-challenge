begin
  SeedData.new.call("test@example.com", "password123")
rescue => e
  puts e.message
end