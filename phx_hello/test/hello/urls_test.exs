defmodule Hello.UrlsTest do
  use Hello.DataCase

  alias Hello.Urls

  describe "urls" do
    alias Hello.Urls.Url

    import Hello.UrlsFixtures

    @invalid_attrs %{link: nil, title: nil}

    test "list_urls/0 returns all urls" do
      url = url_fixture()
      assert Urls.list_urls() == [url]
    end

    test "get_url!/1 returns the url with given id" do
      url = url_fixture()
      assert Urls.get_url!(url.id) == url
    end

    test "create_url/1 with valid data creates a url" do
      valid_attrs = %{link: "some link", title: "some title"}

      assert {:ok, %Url{} = url} = Urls.create_url(valid_attrs)
      assert url.link == "some link"
      assert url.title == "some title"
    end

    test "create_url/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Urls.create_url(@invalid_attrs)
    end

    test "update_url/2 with valid data updates the url" do
      url = url_fixture()
      update_attrs = %{link: "some updated link", title: "some updated title"}

      assert {:ok, %Url{} = url} = Urls.update_url(url, update_attrs)
      assert url.link == "some updated link"
      assert url.title == "some updated title"
    end

    test "update_url/2 with invalid data returns error changeset" do
      url = url_fixture()
      assert {:error, %Ecto.Changeset{}} = Urls.update_url(url, @invalid_attrs)
      assert url == Urls.get_url!(url.id)
    end

    test "delete_url/1 deletes the url" do
      url = url_fixture()
      assert {:ok, %Url{}} = Urls.delete_url(url)
      assert_raise Ecto.NoResultsError, fn -> Urls.get_url!(url.id) end
    end

    test "change_url/1 returns a url changeset" do
      url = url_fixture()
      assert %Ecto.Changeset{} = Urls.change_url(url)
    end
  end
end
