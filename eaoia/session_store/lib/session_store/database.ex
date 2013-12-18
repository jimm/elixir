use Amnesia

defdatabase SessionStore.Database do

  deftable User, [id: :autoincrement, name: ""], type: :bag, index: [:name] do
  end

  deftable Project, [title: "", description: ""], type: :bag do
  end

  deftable Contributor, [user_id: 0, title: ""], type: :bag, index: [:title] do
  end

end
