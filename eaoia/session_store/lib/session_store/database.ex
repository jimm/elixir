use Amnesia

defdatabase SessionStore.Database do

  deftable User, [id: 0, name: ""] do
  end
  
  deftable Project, [title: "", description: ""] do
  end

  deftable Contributer, [user_id: 0, title: ""], type: :bag do
  end

end
