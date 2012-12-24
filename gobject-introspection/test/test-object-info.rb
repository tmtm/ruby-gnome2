# Copyright (C) 2012  Ruby-GNOME2 Project Team
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

class TestObjectInfo < Test::Unit::TestCase
  def setup
    @repository = GObjectIntrospection::Repository.default
    @repository.require("GObject")
    @repository.require("Gio")
    @info = @repository.find("GObject", "Object")
  end

  def test_type_name
    assert_equal("GObject", @info.type_name)
  end

  def test_type_init
    assert_equal("g_object_get_type", @info.type_init)
  end

  def test_abstract?
    assert_false(@info.abstract?)
  end

  def test_fundamental?
    assert_false(@info.fundamental?)
  end

  def test_parent
    info = @repository.find("Gio", "FileOutputStream")
    assert_equal("OutputStream", info.parent.name)
  end
end