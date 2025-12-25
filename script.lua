local Rayfield = loadstring(game:HttpGet(
"https://raw.githubusercontent.com/shlexware/Rayfield/main/source"
))()

local Window = Rayfield:CreateWindow({
   Name = "Egg Finders",
   LoadingTitle = "Chargement",
   LoadingSubtitle = "by Someone",
   KeySystem = false
})

local Tab = Window:CreateTab("Main")

Tab:CreateButton({
   Name = "Test GUI",
   Callback = function()
      Rayfield:Notify({
         Title = "OK",
         Content = "🎉",
         Duration = 4
      })
   end
})
